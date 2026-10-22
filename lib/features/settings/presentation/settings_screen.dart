import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:yam/app/session/session_profile.dart';
import 'package:yam/app/theme/app_breakpoints.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/ui/lists/yam_settings_list.dart';
import 'package:yam/core/ui/motion/yam_entrance_reveal.dart';
import 'package:yam/features/backup/data/backup_file_service.dart';
import 'package:yam/features/backup/data/backup_repository.dart';
import 'package:yam/features/backup/presentation/backup_settings_section.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.appVersion,
    required this.themeMode,
    required this.onThemeModeChanged,
    this.profile,
    this.currentWeightKg,
    this.backupRepository,
    this.backupFiles,
    this.onBackupImported,
    super.key,
  });

  final String appVersion;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final SessionProfile? profile;
  final double? currentWeightKg;
  final BackupRepository? backupRepository;
  final BackupFileService? backupFiles;
  final VoidCallback? onBackupImported;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final numbers = NumberFormat.decimalPattern(locale.toLanguageTag());
    final weightNumbers = NumberFormat.decimalPattern(locale.toLanguageTag())
      ..minimumFractionDigits = 0
      ..maximumFractionDigits = 1;
    final goalsSummary = profile == null
        ? l10n.settingsGoalsNotSet
        : l10n.settingsGoalsSummary(
            numbers.format(profile!.calorieTarget),
            numbers.format(profile!.proteinTarget),
            numbers.format(profile!.fatTarget),
            numbers.format(profile!.carbsTarget),
          );
    final weightSummary = currentWeightKg == null && profile == null
        ? l10n.settingsWeightNotSet
        : l10n.settingsWeightSummary(
            currentWeightKg == null
                ? '—'
                : weightNumbers.format(currentWeightKg),
            profile == null
                ? '—'
                : weightNumbers.format(profile!.targetWeightKg),
          );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding =
                constraints.maxWidth >= AppBreakpoints.navigationRail
                ? AppSpacing.xl
                : AppSpacing.md;

            return CustomScrollView(
              key: const ValueKey('settings-scroll-view'),
              slivers: [
                _SettingsHeader(horizontalPadding: horizontalPadding),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    AppSpacing.md,
                    horizontalPadding,
                    AppSpacing.xl,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 680),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            YamEntranceReveal(
                              index: 0,
                              child: YamSettingsSection(
                                title: l10n.settingsGoalsSection,
                                children: [
                                  YamSettingsRow(
                                    title: l10n.settingsGoalsNutrition,
                                    subtitle: goalsSummary,
                                    minHeight: 56,
                                  ),
                                  YamSettingsRow(
                                    title: l10n.settingsWeight,
                                    subtitle: weightSummary,
                                    minHeight: 56,
                                  ),
                                  YamSettingsRow(
                                    key: const ValueKey('settings-onboarding'),
                                    title: l10n.settingsOpenOnboarding,
                                    showChevron: true,
                                    onPressed: () =>
                                        context.push('/onboarding'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            YamEntranceReveal(
                              index: 1,
                              child: YamSettingsSection(
                                title: l10n.settingsApplicationSection,
                                children: [
                                  YamSettingsRow(
                                    key: const ValueKey('settings-theme'),
                                    title: l10n.settingsTheme,
                                    value: _themeModeLabel(l10n, themeMode),
                                    showChevron: true,
                                    onPressed: () => _showThemePicker(context),
                                  ),
                                  YamSettingsRow(
                                    title: l10n.settingsUnits,
                                    value: l10n.settingsUnitsMetric,
                                  ),
                                  YamSettingsRow(
                                    title: l10n.settingsLanguage,
                                    value: locale.languageCode == 'ru'
                                        ? l10n.settingsLanguageRussian
                                        : l10n.settingsLanguageEnglish,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            YamEntranceReveal(
                              index: 2,
                              child: backupRepository == null
                                  ? YamSettingsSection(
                                      title: l10n.settingsDataSection,
                                      children: [
                                        YamSettingsRow(
                                          key: const ValueKey(
                                            'settings-export',
                                          ),
                                          title: l10n.settingsExportData,
                                          value: l10n.settingsUnavailable,
                                          mutedValue: true,
                                        ),
                                        YamSettingsRow(
                                          key: const ValueKey(
                                            'settings-import',
                                          ),
                                          title: l10n.settingsImportData,
                                          value: l10n.settingsUnavailable,
                                          mutedValue: true,
                                        ),
                                        YamSettingsRow(
                                          title: l10n.settingsDeleteAllData,
                                          value: l10n.settingsUnavailable,
                                          tone: YamSettingsRowTone.destructive,
                                          mutedValue: true,
                                        ),
                                      ],
                                    )
                                  : BackupSettingsSection(
                                      repository: backupRepository!,
                                      files:
                                          backupFiles ??
                                          const BackupFileService(),
                                      onImported: onBackupImported,
                                    ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            YamEntranceReveal(
                              index: 3,
                              child: YamSettingsSection(
                                title: l10n.settingsAboutSection,
                                children: [
                                  YamSettingsRow(
                                    key: const ValueKey('settings-about'),
                                    title: l10n.settingsAboutYam,
                                    showChevron: true,
                                    onPressed: () => _showAbout(context),
                                  ),
                                  YamSettingsRow(
                                    title: l10n.settingsVersion,
                                    value: appVersion,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _showThemePicker(BuildContext context) async {
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 480),
      builder: (context) => _ThemePicker(selectedMode: themeMode),
    );
    if (selected != null && selected != themeMode) {
      onThemeModeChanged(selected);
    }
  }

  void _showAbout(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showAboutDialog(
      context: context,
      applicationName: l10n.appName,
      applicationVersion: appVersion,
      applicationIcon: Icon(
        Icons.restaurant_menu_rounded,
        color: Theme.of(context).colorScheme.primary,
      ),
      children: [Text(l10n.settingsAboutDescription)],
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.horizontalPadding});

  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      pinned: true,
      primary: false,
      toolbarHeight: 56,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Semantics(
                header: true,
                child: Text(
                  AppLocalizations.of(context).settingsTitle,
                  style: AppTypography.sectionTitle.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker({required this.selectedMode});

  final ThemeMode selectedMode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                l10n.settingsTheme,
                style: AppTypography.sectionTitle.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            for (final mode in ThemeMode.values)
              _ThemeModeRow(
                key: ValueKey('settings-theme-${mode.name}'),
                label: _themeModeLabel(l10n, mode),
                selected: selectedMode == mode,
                onPressed: () => Navigator.of(context).pop(mode),
              ),
          ],
        ),
      ),
    );
  }
}

class _ThemeModeRow extends StatelessWidget {
  const _ThemeModeRow({
    required this.label,
    required this.selected,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.control),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.productTitle.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _themeModeLabel(AppLocalizations l10n, ThemeMode mode) {
  return switch (mode) {
    ThemeMode.system => l10n.settingsThemeSystem,
    ThemeMode.light => l10n.settingsThemeLight,
    ThemeMode.dark => l10n.settingsThemeDark,
  };
}
