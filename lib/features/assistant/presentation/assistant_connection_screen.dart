import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';
import 'package:yam/core/ui/forms/yam_select_field.dart';
import 'package:yam/core/ui/forms/yam_text_field.dart';
import 'package:yam/core/ui/selection/yam_dropdown.dart';
import 'package:yam/features/assistant/data/assistant_connection_manager.dart';
import 'package:yam/features/assistant/domain/assistant_models.dart';
import 'package:yam/features/assistant/presentation/assistant_failure_text.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class AssistantConnectionScreen extends StatefulWidget {
  const AssistantConnectionScreen({required this.connection, super.key});
  final AssistantConnectionManager connection;

  @override
  State<AssistantConnectionScreen> createState() =>
      _AssistantConnectionScreenState();
}

class _AssistantConnectionScreenState extends State<AssistantConnectionScreen> {
  final _apiKey = TextEditingController();
  String? _failure;
  bool _welcomeOpen = false;

  @override
  void initState() {
    super.initState();
    widget.connection.addListener(_connectionChanged);
    unawaited(_act(widget.connection.initialize));
  }

  void _connectionChanged() {
    if (!mounted) return;
    setState(() {});
    if (widget.connection.needsPlanWelcome && !_welcomeOpen) {
      _welcomeOpen = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _welcome());
    }
  }

  Future<void> _welcome() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.assistantPlanWelcomeTitle),
        content: Text(l10n.assistantPlanWelcome),
        actions: [
          YamTextButton(
            label: l10n.backupDone,
            tone: YamTextButtonTone.accent,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
    await _act(widget.connection.acknowledgePlanWelcome);
    _welcomeOpen = false;
  }

  Future<void> _act(Future<void> Function() action) async {
    if (mounted) setState(() => _failure = null);
    try {
      await action();
    } on AssistantFailure catch (failure) {
      if (mounted) setState(() => _failure = failure.code);
    } catch (_) {
      if (mounted) setState(() => _failure = 'request_failed');
    }
  }

  @override
  void dispose() {
    widget.connection.removeListener(_connectionChanged);
    widget.connection.cancelSignIn();
    _apiKey.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final connection = widget.connection;
    final colors = Theme.of(context).colorScheme;
    final error = _failure ?? connection.failureCode;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.assistantSettings)),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(l10n.assistantPrivacy, style: AppTypography.body),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.assistantSessionNote,
                  style: AppTypography.caption.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (connection.isConnected) ...[
                  Text(
                    '${l10n.assistantConnected}${connection.accountLabel == null ? '' : ': ${connection.accountLabel}'}',
                    style: AppTypography.productTitle,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                YamSelectField<AssistantConnectionMode>(
                  label: l10n.assistantConnectionMode,
                  value: connection.mode,
                  items: [
                    YamDropdownOption(
                      value: AssistantConnectionMode.chatgpt,
                      label: l10n.assistantChatGpt,
                    ),
                    YamDropdownOption(
                      value: AssistantConnectionMode.apiKey,
                      label: l10n.assistantApiKey,
                    ),
                  ],
                  onChanged: connection.isLoading
                      ? null
                      : (mode) => _act(() => connection.selectMode(mode)),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(l10n.assistantChatGpt, style: AppTypography.sectionTitle),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.assistantPlanNote,
                  style: AppTypography.label.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (connection.activeChatGptClientId != null &&
                    connection.savedChatGptAccounts.any(
                      (account) =>
                          account.clientId == connection.activeChatGptClientId,
                    )) ...[
                  YamSelectField<String>(
                    label: l10n.assistantChatGptAccount,
                    value: connection.activeChatGptClientId!,
                    items: [
                      for (final account in connection.savedChatGptAccounts)
                        YamDropdownOption(
                          value: account.clientId,
                          label: account.label,
                        ),
                    ],
                    onChanged: connection.isLoading
                        ? null
                        : (id) =>
                              _act(() => connection.selectChatGptAccount(id)),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                YamSecondaryButton(
                  key: const ValueKey('assistant-chatgpt-connect'),
                  label: l10n.assistantChatGptContinue,
                  icon: Icons.login_rounded,
                  onPressed: connection.isLoading
                      ? null
                      : () => _act(connection.signInChatGpt),
                ),
                if (connection.savedChatGptAccounts.isNotEmpty)
                  YamTextButton(
                    label: l10n.assistantAddChatGptAccount,
                    onPressed: connection.isLoading
                        ? null
                        : () => _act(connection.addChatGptAccount),
                  ),
                if (connection.isLoading) ...[
                  const SizedBox(height: AppSpacing.xs),
                  const LinearProgressIndicator(),
                  YamTextButton(
                    label: l10n.backupCancel,
                    onPressed: connection.cancelSignIn,
                  ),
                ],
                YamTextButton(
                  label: l10n.assistantManageUsage,
                  icon: Icons.open_in_new_rounded,
                  onPressed: () => _act(() async {
                    if (!await launchUrl(
                      Uri.parse('https://chatgpt.com/settings/usage'),
                      mode: LaunchMode.externalApplication,
                    )) {
                      throw const AssistantFailure('network');
                    }
                  }),
                ),
                const Divider(height: AppSpacing.xl),
                Text(l10n.assistantApiKey, style: AppTypography.sectionTitle),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.assistantApiKeyNote,
                  style: AppTypography.label.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                YamTextField(
                  fieldKey: const ValueKey('assistant-api-key'),
                  label: l10n.assistantApiKeyLabel,
                  controller: _apiKey,
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppSpacing.sm),
                YamSecondaryButton(
                  key: const ValueKey('assistant-api-key-connect'),
                  label: l10n.assistantSaveKey,
                  onPressed: connection.isLoading || _apiKey.text.trim().isEmpty
                      ? null
                      : () => _act(() async {
                          await connection.connectApiKey(_apiKey.text.trim());
                          if (connection.failureCode == null) _apiKey.clear();
                        }),
                ),
                if (connection.models.isNotEmpty &&
                    connection.model != null &&
                    connection.models.any(
                      (model) => model.id == connection.model,
                    )) ...[
                  const Divider(height: AppSpacing.xl),
                  YamSelectField<String>(
                    label: l10n.assistantModel,
                    value: connection.model!,
                    items: [
                      for (final model in connection.models)
                        YamDropdownOption(value: model.id, label: model.label),
                    ],
                    onChanged: connection.isLoading
                        ? null
                        : (model) => _act(() => connection.selectModel(model)),
                  ),
                ],
                if (connection.isConnected) ...[
                  YamTextButton(
                    label: l10n.assistantRefreshModels,
                    onPressed: connection.isLoading
                        ? null
                        : () => _act(
                            () => connection.selectMode(connection.mode),
                          ),
                  ),
                  YamTextButton(
                    label: l10n.assistantDisconnect,
                    tone: YamTextButtonTone.destructive,
                    onPressed: connection.isLoading
                        ? null
                        : () => _act(connection.disconnect),
                  ),
                ],
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        assistantFailureText(l10n, error),
                        style: AppTypography.label.copyWith(
                          color: colors.error,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
