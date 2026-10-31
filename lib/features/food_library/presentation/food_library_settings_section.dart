import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';
import 'package:yam/core/ui/feedback/yam_action_sheet.dart';
import 'package:yam/core/ui/feedback/yam_snack_bar.dart';
import 'package:yam/core/ui/lists/yam_settings_list.dart';
import 'package:yam/features/food_library/data/food_library_file_service.dart';
import 'package:yam/features/food_library/data/food_library_repository.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class FoodLibrarySettingsSection extends StatefulWidget {
  const FoodLibrarySettingsSection({
    required this.repository,
    this.files = const FoodLibraryFileService(),
    super.key,
  });

  final FoodLibraryRepository repository;
  final FoodLibraryFileService files;

  @override
  State<FoodLibrarySettingsSection> createState() =>
      _FoodLibrarySettingsSectionState();
}

class _FoodLibrarySettingsSectionState
    extends State<FoodLibrarySettingsSection> {
  bool _busy = false;

  void _setBusy(bool busy) {
    if (mounted) setState(() => _busy = busy);
  }

  Future<T?> _showSheet<T>({
    required String title,
    required List<Widget> Function(BuildContext, ValueChanged<T?>) content,
  }) => showYamActionSheet<T>(
    context: context,
    title: title,
    closeLabel: AppLocalizations.of(context).backupClose,
    content: content,
  );

  void _showFailure(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _failureMessage(AppLocalizations l10n, FoodLibraryException error) =>
      switch (error.failure) {
        FoodLibraryFailure.invalidFile =>
          error.path == null
              ? l10n.foodLibraryInvalidFile
              : l10n.foodLibraryInvalidField(error.path!),
        FoodLibraryFailure.unsupportedVersion =>
          l10n.foodLibraryUnsupportedVersion,
        FoodLibraryFailure.tooLarge => l10n.foodLibraryTooLarge,
      };

  Future<void> _export() async {
    if (_busy) return;
    _setBusy(true);
    final l10n = AppLocalizations.of(context);
    try {
      final bytes = await widget.repository.exportLibrary();
      if (!mounted) return;
      final timestamp = DateTime.now()
          .toUtc()
          .toIso8601String()
          .split('.')
          .first
          .replaceAll(':', '-');
      final saved = await widget.files.saveLibrary(
        bytes,
        fileName: 'yam-foods-$timestamp.json',
        dialogTitle: l10n.foodLibrarySaveDialog,
      );
      if (saved && mounted) {
        showYamSuccessSnackBar(
          context: context,
          message: l10n.foodLibraryExportSuccess,
        );
      }
    } on FoodLibraryException catch (error) {
      _showFailure(_failureMessage(l10n, error));
    } catch (_) {
      _showFailure(l10n.foodLibraryExportFailed);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> _import() async {
    if (_busy) return;
    _setBusy(true);
    final l10n = AppLocalizations.of(context);
    try {
      final bytes = await widget.files.openLibrary(
        dialogTitle: l10n.foodLibraryOpenDialog,
      );
      if (bytes == null || !mounted) return;
      final preview = await widget.repository.inspectLibrary(bytes);
      if (!mounted) return;
      final mode = await _chooseMode(preview);
      if (mode == null || !mounted) return;
      if (mode == FoodLibraryImportMode.replace) {
        final confirmed = await _showSheet<bool>(
          title: l10n.foodLibraryReplaceTitle,
          content: (context, close) => [
            Text(l10n.foodLibraryReplaceWarning),
            const SizedBox(height: AppSpacing.lg),
            YamTextButton(
              key: const ValueKey('food-library-confirm-replace'),
              label: l10n.foodLibraryReplaceConfirm,
              tone: YamTextButtonTone.destructive,
              onPressed: () => close(true),
            ),
            YamTextButton(
              label: l10n.backupCancel,
              onPressed: () => close(false),
            ),
          ],
        );
        if (confirmed != true || !mounted) return;
      }
      final result = await widget.repository.importLibrary(preview, mode);
      if (!mounted) return;
      final numbers = NumberFormat.decimalPattern(
        Localizations.localeOf(context).toLanguageTag(),
      );
      await _showSheet<bool>(
        title: l10n.foodLibraryImportComplete,
        content: (context, close) => [
          Text(
            l10n.foodLibraryImportResult(
              numbers.format(result.imported),
              numbers.format(result.skipped),
              numbers.format(result.replaced),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.foodLibraryResultNote),
          const SizedBox(height: AppSpacing.lg),
          YamPrimaryButton(
            key: const ValueKey('food-library-import-done'),
            label: l10n.backupDone,
            expanded: true,
            onPressed: () => close(true),
          ),
        ],
      );
    } on FoodLibraryException catch (error) {
      _showFailure(_failureMessage(l10n, error));
    } catch (_) {
      _showFailure(l10n.foodLibraryImportFailed);
    } finally {
      _setBusy(false);
    }
  }

  Future<FoodLibraryImportMode?> _chooseMode(FoodLibraryPreview preview) {
    final l10n = AppLocalizations.of(context);
    final numbers = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    );
    return _showSheet<FoodLibraryImportMode>(
      title: l10n.foodLibraryPreviewTitle,
      content: (context, close) => [
        Text(
          l10n.foodLibraryPreviewCounts(
            numbers.format(preview.foodCount),
            numbers.format(preview.servingCount),
          ),
          style: AppTypography.productTitle,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(l10n.foodLibraryScopeNote),
        const SizedBox(height: AppSpacing.lg),
        Text(l10n.foodLibraryDeduplicateDescription),
        const SizedBox(height: AppSpacing.xs),
        YamPrimaryButton(
          key: const ValueKey('food-library-merge-deduplicated'),
          label: l10n.foodLibraryDeduplicate,
          expanded: true,
          onPressed: () => close(FoodLibraryImportMode.mergeDeduplicated),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(l10n.foodLibraryMergeAllDescription),
        const SizedBox(height: AppSpacing.xs),
        YamSecondaryButton(
          key: const ValueKey('food-library-merge-all'),
          label: l10n.foodLibraryMergeAll,
          expanded: true,
          onPressed: () => close(FoodLibraryImportMode.mergeAll),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(l10n.foodLibraryReplaceDescription),
        const SizedBox(height: AppSpacing.xs),
        YamTextButton(
          key: const ValueKey('food-library-replace'),
          label: l10n.foodLibraryReplace,
          tone: YamTextButtonTone.destructive,
          onPressed: () => close(FoodLibraryImportMode.replace),
        ),
        YamTextButton(
          key: const ValueKey('food-library-cancel-import'),
          label: l10n.backupCancel,
          onPressed: () => close(null),
        ),
      ],
    );
  }

  Future<void> _showFormat() async {
    if (_busy) return;
    _setBusy(true);
    final l10n = AppLocalizations.of(context);
    final example = const JsonEncoder.withIndent('  ').convert({
      'format': 'yam-foods',
      'version': 1,
      'foods': [
        {
          'name': l10n.foodLibraryExampleName,
          'category': l10n.foodLibraryExampleCategory,
          'unit': 'g',
          'basisAmount': 100,
          'kcal': 121,
          'protein': 17,
          'fat': 5,
          'carbs': 2,
        },
      ],
    });
    try {
      await _showSheet<bool>(
        title: l10n.foodLibraryFormatTitle,
        content: (context, close) => [
          Text(l10n.foodLibraryFormatDescription),
          const SizedBox(height: AppSpacing.md),
          SelectableText(example, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.foodLibraryOptionalFields),
          const SizedBox(height: AppSpacing.lg),
          YamPrimaryButton(
            key: const ValueKey('food-library-copy-example'),
            label: l10n.foodLibraryCopyExample,
            expanded: true,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: example));
              if (context.mounted) close(true);
            },
          ),
        ],
      );
    } finally {
      _setBusy(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        YamSettingsSection(
          title: l10n.foodLibrarySection,
          children: [
            YamSettingsRow(
              key: const ValueKey('food-library-export'),
              title: l10n.foodLibraryExport,
              subtitle: l10n.foodLibraryExportHint,
              showChevron: true,
              onPressed: _busy ? null : _export,
            ),
            YamSettingsRow(
              key: const ValueKey('food-library-import'),
              title: l10n.foodLibraryImport,
              subtitle: l10n.foodLibraryImportHint,
              showChevron: true,
              onPressed: _busy ? null : _import,
            ),
            YamSettingsRow(
              key: const ValueKey('food-library-format'),
              title: l10n.foodLibraryFormatTitle,
              showChevron: true,
              onPressed: _busy ? null : _showFormat,
            ),
          ],
        ),
        if (_busy)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Semantics(
              liveRegion: true,
              child: Text(
                l10n.foodLibraryWorking,
                style: AppTypography.caption,
              ),
            ),
          ),
      ],
    );
  }
}
