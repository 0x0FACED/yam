import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';
import 'package:yam/core/ui/feedback/yam_snack_bar.dart';
import 'package:yam/core/ui/lists/yam_settings_list.dart';
import 'package:yam/features/backup/data/backup_file_service.dart';
import 'package:yam/features/backup/data/backup_repository.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class BackupSettingsSection extends StatelessWidget {
  const BackupSettingsSection({
    required this.repository,
    this.files = const BackupFileService(),
    this.onImported,
    super.key,
  });

  final BackupRepository repository;
  final BackupFileService files;
  final VoidCallback? onImported;

  @override
  Widget build(BuildContext context) => _BackupActions(
    repository: repository,
    files: files,
    onImported: onImported,
    builder: (context, progress, onExport, onImport) {
      final l10n = AppLocalizations.of(context);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          YamSettingsSection(
            title: l10n.settingsDataSection,
            children: [
              Semantics(
                enabled: progress == null,
                button: true,
                child: YamSettingsRow(
                  key: const ValueKey('settings-export'),
                  title: l10n.settingsExportData,
                  showChevron: true,
                  onPressed: progress == null ? onExport : null,
                ),
              ),
              Semantics(
                enabled: progress == null,
                button: true,
                child: YamSettingsRow(
                  key: const ValueKey('settings-import'),
                  title: l10n.settingsImportData,
                  showChevron: true,
                  onPressed: progress == null ? onImport : null,
                ),
              ),
              YamSettingsRow(
                title: l10n.settingsDeleteAllData,
                value: l10n.settingsUnavailable,
                tone: YamSettingsRowTone.destructive,
                mutedValue: true,
              ),
            ],
          ),
          if (progress != null) _BackupProgress(message: progress),
        ],
      );
    },
  );
}

/// Restores a backup without bypassing the required first-run profile gate.
class BackupImportButton extends StatelessWidget {
  const BackupImportButton({
    required this.repository,
    this.files = const BackupFileService(),
    this.onImported,
    this.onBusyChanged,
    super.key,
  });

  final BackupRepository repository;
  final BackupFileService files;
  final VoidCallback? onImported;
  final ValueChanged<bool>? onBusyChanged;

  @override
  Widget build(BuildContext context) => _BackupActions(
    repository: repository,
    files: files,
    onImported: onImported,
    onBusyChanged: onBusyChanged,
    builder: (context, progress, onExport, onImport) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        YamTextButton(
          key: const ValueKey('backup-restore'),
          label: AppLocalizations.of(context).backupRestoreAction,
          icon: Icons.restore_rounded,
          tone: YamTextButtonTone.accent,
          onPressed: progress == null ? onImport : null,
        ),
        if (progress != null) _BackupProgress(message: progress),
      ],
    ),
  );
}

typedef _BackupActionBuilder =
    Widget Function(
      BuildContext context,
      String? progress,
      VoidCallback onExport,
      VoidCallback onImport,
    );

class _BackupActions extends StatefulWidget {
  const _BackupActions({
    required this.repository,
    required this.files,
    required this.builder,
    this.onImported,
    this.onBusyChanged,
  });

  final BackupRepository repository;
  final BackupFileService files;
  final _BackupActionBuilder builder;
  final VoidCallback? onImported;
  final ValueChanged<bool>? onBusyChanged;

  @override
  State<_BackupActions> createState() => _BackupActionsState();
}

enum _BackupActivity {
  confirming,
  exporting,
  saving,
  opening,
  inspecting,
  importing,
}

class _BackupActionsState extends State<_BackupActions> {
  _BackupActivity? _activity;

  void _setActivity(_BackupActivity? activity) {
    if (!mounted) return;
    final wasBusy = _activity != null;
    setState(() => _activity = activity);
    if (wasBusy != (activity != null)) {
      widget.onBusyChanged?.call(activity != null);
    }
  }

  Future<void> _exportBackup() async {
    if (_activity != null) return;
    _setActivity(_BackupActivity.confirming);
    final l10n = AppLocalizations.of(context);
    try {
      if (await _confirm(replace: false) != true || !mounted) return;
      _setActivity(_BackupActivity.exporting);
      final bytes = await widget.repository.exportBackup();
      if (!mounted) return;
      _setActivity(_BackupActivity.saving);
      final timestamp = DateTime.now()
          .toUtc()
          .toIso8601String()
          .split('.')
          .first
          .replaceAll(':', '-');
      final saved = await widget.files.saveBackup(
        bytes,
        fileName: 'yam-backup-$timestamp.yam',
        dialogTitle: l10n.backupSaveDialogTitle,
      );
      if (saved && mounted) {
        showYamSuccessSnackBar(
          context: context,
          message: l10n.backupExportSuccess,
        );
      }
    } on BackupException catch (error) {
      _showFailure(switch (error.failure) {
        BackupFailure.invalidFile => l10n.backupExportInvalidData,
        BackupFailure.unsupportedVersion => l10n.backupExportFailed,
        BackupFailure.tooLarge => l10n.backupTooLarge,
      });
    } catch (_) {
      _showFailure(l10n.backupExportFailed);
    } finally {
      _setActivity(null);
    }
  }

  Future<void> _importBackup() async {
    if (_activity != null) return;
    _setActivity(_BackupActivity.opening);
    final l10n = AppLocalizations.of(context);
    final onImported = widget.onImported;
    BackupImportResult? result;
    try {
      result = await _readAndImport(l10n);
    } on BackupException catch (error) {
      _showFailure(_failureMessage(l10n, error.failure));
    } catch (_) {
      _showFailure(l10n.backupImportFailed);
    }

    if (result == null) {
      _setActivity(null);
      return;
    }
    try {
      if (mounted) await _showImportResult(result);
    } finally {
      _setActivity(null);
      // A committed import must reload the host even if this screen went away.
      // The callback can replace the router, so do not use context after it.
      onImported?.call();
    }
  }

  Future<BackupImportResult?> _readAndImport(AppLocalizations l10n) async {
    final bytes = await widget.files.openBackup(
      dialogTitle: l10n.backupOpenDialogTitle,
    );
    if (bytes == null || !mounted) return null;
    _setActivity(_BackupActivity.inspecting);
    final preview = await widget.repository.inspectBackup(bytes);
    if (!mounted) return null;
    _setActivity(_BackupActivity.confirming);
    final mode = await _chooseImportMode(preview);
    if (mode == null || !mounted) return null;
    if (mode == BackupImportMode.replace) {
      if (await _confirm(replace: true) != true || !mounted) return null;
    }
    _setActivity(_BackupActivity.importing);
    return widget.repository.importBackup(preview, mode);
  }

  String _failureMessage(AppLocalizations l10n, BackupFailure failure) =>
      switch (failure) {
        BackupFailure.invalidFile => l10n.backupInvalidFile,
        BackupFailure.unsupportedVersion => l10n.backupUnsupportedVersion,
        BackupFailure.tooLarge => l10n.backupTooLarge,
      };

  void _showFailure(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<T?> _showSheet<T>({
    required String title,
    required List<Widget> Function(BuildContext, ValueChanged<T?>) content,
  }) {
    dismissYamSnackBar(context);
    var closed = false;
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (sheetContext) {
        void close(T? result) {
          if (closed || ModalRoute.of(sheetContext)?.isCurrent != true) return;
          closed = true;
          Navigator.of(sheetContext).pop(result);
        }

        return _BackupSheet(
          title: title,
          onClose: () => close(null),
          children: content(sheetContext, close),
        );
      },
    );
  }

  Future<bool?> _confirm({required bool replace}) {
    final l10n = AppLocalizations.of(context);
    return _showSheet<bool>(
      title: replace ? l10n.backupReplaceTitle : l10n.settingsExportData,
      content: (context, close) => [
        Text(replace ? l10n.backupReplaceWarning : l10n.backupPersonalDataNote),
        const SizedBox(height: AppSpacing.lg),
        if (replace)
          YamTextButton(
            key: const ValueKey('backup-confirm-replace'),
            label: l10n.backupReplaceConfirm,
            tone: YamTextButtonTone.destructive,
            onPressed: () => close(true),
          )
        else
          YamPrimaryButton(
            key: const ValueKey('backup-confirm-export'),
            label: l10n.backupSaveAction,
            icon: Icons.save_alt_rounded,
            expanded: true,
            onPressed: () => close(true),
          ),
        const SizedBox(height: AppSpacing.xs),
        YamTextButton(
          key: ValueKey(
            replace ? 'backup-cancel-replace' : 'backup-cancel-export',
          ),
          label: l10n.backupCancel,
          onPressed: () => close(false),
        ),
      ],
    );
  }

  Future<BackupImportMode?> _chooseImportMode(BackupPreview preview) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateFormat.yMMMd(
      locale,
    ).add_jm().format(preview.exportedAt.toLocal());
    return _showSheet<BackupImportMode>(
      title: l10n.backupPreviewTitle,
      content: (context, close) => [
        Text(l10n.backupExportedAt(date)),
        const SizedBox(height: AppSpacing.md),
        _BackupCountsSummary(counts: preview.counts),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.backupCountsNote,
          style: AppTypography.caption.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(l10n.backupSupplementDescription),
        const SizedBox(height: AppSpacing.xs),
        YamPrimaryButton(
          key: const ValueKey('backup-supplement'),
          label: l10n.backupSupplementAction,
          expanded: true,
          onPressed: () => close(BackupImportMode.supplement),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(l10n.backupReplaceDescription),
        const SizedBox(height: AppSpacing.xs),
        YamSecondaryButton(
          key: const ValueKey('backup-replace'),
          label: l10n.backupReplaceAction,
          expanded: true,
          onPressed: () => close(BackupImportMode.replace),
        ),
        const SizedBox(height: AppSpacing.xs),
        YamTextButton(
          key: const ValueKey('backup-cancel-import'),
          label: l10n.backupCancel,
          onPressed: () => close(null),
        ),
      ],
    );
  }

  Future<void> _showImportResult(BackupImportResult result) async {
    final l10n = AppLocalizations.of(context);
    final numbers = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    );
    await _showSheet<bool>(
      title: l10n.backupImportComplete,
      content: (context, close) => [
        Text(
          l10n.backupImportResult(
            numbers.format(result.imported.total),
            numbers.format(result.skipped.total),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(l10n.backupImportedRecords, style: AppTypography.productTitle),
        const SizedBox(height: AppSpacing.xs),
        _BackupCountsSummary(counts: result.imported),
        if (result.skipped.total > 0) ...[
          const SizedBox(height: AppSpacing.md),
          Text(l10n.backupSkippedRecords, style: AppTypography.productTitle),
          const SizedBox(height: AppSpacing.xs),
          _BackupCountsSummary(counts: result.skipped),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.backupSkippedNote),
        ],
        const SizedBox(height: AppSpacing.lg),
        YamPrimaryButton(
          key: const ValueKey('backup-import-done'),
          label: l10n.backupDone,
          expanded: true,
          onPressed: () => close(true),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final activity = _activity;
    final progress = switch (activity) {
      null => null,
      _BackupActivity.confirming => l10n.backupWaitingForConfirmation,
      _BackupActivity.exporting => l10n.backupExporting,
      _BackupActivity.saving => l10n.backupSaving,
      _BackupActivity.opening => l10n.backupOpening,
      _BackupActivity.inspecting => l10n.backupInspecting,
      _BackupActivity.importing => l10n.backupImporting,
    };
    return widget.builder(context, progress, _exportBackup, _importBackup);
  }
}

class _BackupProgress extends StatelessWidget {
  const _BackupProgress({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.xxs,
      AppSpacing.sm,
      AppSpacing.xxs,
      0,
    ),
    child: Semantics(
      liveRegion: true,
      child: Row(
        children: [
          const SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(child: Text(message, style: AppTypography.caption)),
        ],
      ),
    ),
  );
}

class _BackupSheet extends StatelessWidget {
  const _BackupSheet({
    required this.title,
    required this.onClose,
    required this.children,
  });

  final String title;
  final VoidCallback onClose;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(title, style: AppTypography.sectionTitle),
                  ),
                ),
                YamIconButton(
                  icon: Icons.close_rounded,
                  tooltip: AppLocalizations.of(context).backupClose,
                  surface: false,
                  onPressed: onClose,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _BackupCountsSummary extends StatelessWidget {
  const _BackupCountsSummary({required this.counts});

  final BackupCounts counts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final numbers = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    );
    final rows = [
      (l10n.backupCountUserFoods, counts.userFoods),
      (l10n.backupCountUserServings, counts.userServings),
      (l10n.backupCountDiaryEntries, counts.diaryEntries),
      (l10n.backupCountGoals, counts.goals),
      (l10n.backupCountWeights, counts.weights),
      (l10n.backupCountRemoteFoods, counts.remoteFoods),
    ];
    return Column(
      children: [
        for (final (label, count) in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(label)),
                const SizedBox(width: AppSpacing.md),
                Text(
                  numbers.format(count),
                  style: AppTypography.body.copyWith(
                    fontFeatures: AppTypography.tabularFigures,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
