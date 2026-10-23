import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';
import 'package:yam/core/ui/lists/yam_settings_list.dart';
import 'package:yam/features/app_update/domain/app_update.dart';
import 'package:yam/features/app_update/presentation/app_update_controller.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class AppUpdateSettingsSection extends StatefulWidget {
  const AppUpdateSettingsSection({required this.controller, super.key});

  final AppUpdateController controller;

  @override
  State<AppUpdateSettingsSection> createState() =>
      _AppUpdateSettingsSectionState();
}

class _AppUpdateSettingsSectionState extends State<AppUpdateSettingsSection> {
  @override
  void initState() {
    super.initState();
    _checkInitially();
  }

  @override
  void didUpdateWidget(covariant AppUpdateSettingsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) _checkInitially();
  }

  void _checkInitially() {
    if (widget.controller.status == AppUpdateStatus.idle &&
        widget.controller.failure == null) {
      unawaited(widget.controller.check());
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, child) {
      final controller = widget.controller;
      final l10n = AppLocalizations.of(context);
      final theme = Theme.of(context);
      final locale = Localizations.localeOf(context).toLanguageTag();
      final release = controller.release;
      final status = controller.status;
      final message = switch (status) {
        AppUpdateStatus.idle => l10n.updateCheckHint,
        AppUpdateStatus.checking => l10n.updateChecking,
        AppUpdateStatus.upToDate => l10n.updateUpToDate,
        AppUpdateStatus.available => l10n.updateAvailable(
          release!.version.displayVersion,
        ),
        AppUpdateStatus.downloading => l10n.updateDownloading(
          NumberFormat.percentPattern(locale).format(controller.progress),
        ),
        AppUpdateStatus.ready => l10n.updateReady(
          release!.version.displayVersion,
        ),
        AppUpdateStatus.installing => l10n.updateOpeningInstaller,
      };
      final failure = controller.failure;
      final installFailure = controller.installFailure;
      final error = failure != null
          ? switch (failure) {
              UpdateFailure.unavailable => l10n.updateUnavailable,
              UpdateFailure.network => l10n.updateNetworkError,
              UpdateFailure.rateLimited => l10n.updateRateLimited,
              UpdateFailure.invalidRelease => l10n.updateInvalidRelease,
              UpdateFailure.download => l10n.updateDownloadError,
              UpdateFailure.checksum => l10n.updateChecksumError,
            }
          : switch (installFailure) {
              AppUpdateInstallFailure.permission => l10n.updatePermissionHint,
              AppUpdateInstallFailure.signature => l10n.updateSignatureError,
              AppUpdateInstallFailure.invalidApk => l10n.updateInvalidApk,
              AppUpdateInstallFailure.failed => l10n.updateInstallError,
              null => null,
            };

      return YamSettingsSection(
        title: l10n.updateSection,
        children: [
          Semantics(
            button: true,
            enabled: !controller.busy,
            child: YamSettingsRow(
              key: const ValueKey('settings-check-updates'),
              title: l10n.updateCheckAction,
              subtitle: l10n.updateSource,
              showChevron: !controller.busy,
              onPressed: controller.busy ? null : controller.check,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  liveRegion: status != AppUpdateStatus.downloading,
                  child: Text(
                    message,
                    key: const ValueKey('update-status'),
                    style: AppTypography.body.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      error,
                      style: AppTypography.caption.copyWith(
                        color:
                            installFailure == AppUpdateInstallFailure.permission
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
                if (status == AppUpdateStatus.checking ||
                    status == AppUpdateStatus.downloading) ...[
                  const SizedBox(height: AppSpacing.sm),
                  LinearProgressIndicator(
                    key: const ValueKey('update-progress'),
                    value: status == AppUpdateStatus.downloading
                        ? controller.progress
                        : null,
                    semanticsLabel: message,
                  ),
                ],
                if (status == AppUpdateStatus.available) ...[
                  const SizedBox(height: AppSpacing.sm),
                  YamPrimaryButton(
                    key: const ValueKey('update-download'),
                    label: l10n.updateDownloadAction(
                      NumberFormat.decimalPatternDigits(
                        locale: locale,
                        decimalDigits: 1,
                      ).format(release!.sizeBytes / (1024 * 1024)),
                    ),
                    icon: Icons.download_rounded,
                    onPressed: controller.download,
                  ),
                ],
                if (status == AppUpdateStatus.ready) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.updateInstallHint,
                    style: AppTypography.caption.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  YamPrimaryButton(
                    key: const ValueKey('update-install'),
                    label: l10n.updateInstallAction,
                    icon: Icons.system_update_rounded,
                    onPressed: controller.install,
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    },
  );
}
