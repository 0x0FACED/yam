import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_breakpoints.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';
import 'package:yam/core/ui/forms/yam_select_field.dart';
import 'package:yam/core/ui/feedback/yam_snack_bar.dart';
import 'package:yam/core/ui/forms/yam_text_field.dart';
import 'package:yam/core/ui/selection/yam_dropdown.dart';
import 'package:yam/features/assistant/application/assistant_controller.dart';
import 'package:yam/features/assistant/application/assistant_tools.dart';
import 'package:yam/features/assistant/data/assistant_connection_manager.dart';
import 'package:yam/features/assistant/data/assistant_media_service.dart';
import 'package:yam/features/assistant/domain/assistant_models.dart';
import 'package:yam/features/assistant/presentation/assistant_draft_review.dart';
import 'package:yam/features/assistant/presentation/assistant_failure_text.dart';
import 'package:yam/features/diary/data/diary_repository.dart';
import 'package:yam/features/food_search/data/user_food_repository.dart';
import 'package:yam/features/food_search/presentation/food_search_meals.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({
    required this.database,
    required this.userFoods,
    required this.diary,
    required this.connection,
    required this.day,
    this.mealId = 'breakfast',
    super.key,
  });

  final YamDatabase database;
  final UserFoodRepository userFoods;
  final DiaryRepository diary;
  final AssistantConnectionManager connection;
  final DateTime day;
  final String mealId;

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  late final AssistantMediaService _media;
  AssistantController? _controller;
  AssistantImage? _image;
  String? _mediaFailure;
  bool _consented = false;
  bool _mediaBusy = false;
  bool _allowPop = false;
  bool _closePromptOpen = false;
  bool _hasInput = false;

  @override
  void initState() {
    super.initState();
    _media = AssistantMediaService(
      transcribe: widget.connection.transcribe,
      canTranscribe: () => widget.connection.hasApiKey,
    );
    widget.connection.addListener(_changed);
    _input.addListener(_inputChanged);
    unawaited(_initializeConnection());
  }

  Future<void> _initializeConnection() async {
    try {
      await widget.connection.initialize();
    } on AssistantFailure catch (failure) {
      if (mounted) setState(() => _mediaFailure = failure.code);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final locale = Localizations.localeOf(context);
    _controller = AssistantController(
      tools: AssistantTools(
        database: widget.database,
        userFoods: widget.userFoods,
        diary: widget.diary,
        locale: locale,
      ),
      gateway: () => widget.connection.gateway,
      model: () => widget.connection.model,
      day: widget.day,
      mealId: widget.mealId,
      language: locale.languageCode,
    )..addListener(_changed);
  }

  void _inputChanged() {
    final hasInput = _input.text.trim().isNotEmpty;
    if (_hasInput == hasInput) return;
    _hasInput = hasInput;
    if (mounted) setState(() {});
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  bool get _hasSession =>
      _hasInput ||
      _image != null ||
      _controller?.messages.isNotEmpty == true ||
      _controller?.draft != null ||
      _media.isListening;

  Future<bool> _confirmDiscard({
    bool switching = false,
    bool clearing = false,
  }) async {
    if (!_hasSession) return true;
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              switching
                  ? l10n.assistantSettings
                  : clearing
                  ? l10n.assistantClearTitle
                  : l10n.assistantCloseTitle,
            ),
            content: Text(
              switching ? l10n.assistantSwitchNote : l10n.assistantCloseNote,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.assistantKeepEditing),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  switching
                      ? l10n.backupDone
                      : clearing
                      ? l10n.assistantClear
                      : l10n.assistantCloseConfirm,
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _close() async {
    if (_closePromptOpen || _controller?.saving == true) return;
    _closePromptOpen = true;
    final close = await _confirmDiscard();
    _closePromptOpen = false;
    if (!mounted || !close) return;
    _controller?.cancel();
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pop();
    });
  }

  Future<void> _connectionSettings() async {
    if (_controller?.busy == true ||
        _controller?.saving == true ||
        _mediaBusy) {
      return;
    }
    if (!await _confirmDiscard(switching: true) || !mounted) return;
    await _clearSession();
    if (mounted) await context.push('/assistant/connection');
  }

  Future<void> _clearSession() async {
    await _media.cancelSpeech();
    if (!mounted) return;
    _controller?.clear();
    _input.clear();
    setState(() {
      _image = null;
      _mediaFailure = null;
    });
  }

  Future<void> _send() async {
    final controller = _controller!;
    if (controller.busy ||
        controller.saving ||
        _mediaBusy ||
        _media.isListening) {
      return;
    }
    final text = _input.text;
    final image = _image;
    if (text.trim().isEmpty && image == null) return;
    _input.clear();
    setState(() {
      _image = null;
      _mediaFailure = null;
    });
    await controller.send(text, image: image);
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  Future<void> _pickPhoto({bool camera = false}) async {
    setState(() {
      _mediaBusy = true;
      _mediaFailure = null;
    });
    try {
      final image = await _media.pickImage(camera: camera);
      if (mounted && image != null) setState(() => _image = image);
    } on AssistantFailure catch (failure) {
      if (mounted) setState(() => _mediaFailure = failure.code);
    } catch (_) {
      if (mounted) setState(() => _mediaFailure = 'media_failed');
    } finally {
      if (mounted) setState(() => _mediaBusy = false);
    }
  }

  Future<void> _toggleVoice() async {
    final locale = Localizations.localeOf(context).toLanguageTag();
    setState(() {
      _mediaBusy = true;
      _mediaFailure = null;
    });
    final before = _input.text;
    try {
      if (_media.isListening) {
        await _media.stopSpeech();
      } else {
        await _media.startSpeech(
          onListeningChanged: (_) {
            if (mounted) setState(() {});
          },
          locale: locale,
          onText: (text) {
            if (!mounted) return;
            final value = [
              before.trim(),
              text.trim(),
            ].where((part) => part.isNotEmpty).join(' ');
            _input.value = TextEditingValue(
              text: value,
              selection: TextSelection.collapsed(offset: value.length),
            );
            setState(() {});
          },
          onError: (code) {
            if (mounted) setState(() => _mediaFailure = code);
          },
        );
      }
    } on AssistantFailure catch (failure) {
      if (mounted) setState(() => _mediaFailure = failure.code);
    } catch (_) {
      if (mounted) setState(() => _mediaFailure = 'speech_failed');
    } finally {
      if (mounted) setState(() => _mediaBusy = false);
    }
  }

  @override
  void dispose() {
    widget.connection.removeListener(_changed);
    _controller?.removeListener(_changed);
    _controller?.dispose();
    unawaited(_media.dispose());
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = _controller!;
    final connection = widget.connection;
    final colors = Theme.of(context).colorScheme;
    final error =
        _mediaFailure ?? controller.failureCode ?? connection.failureCode;
    final disabled = controller.busy || controller.saving || _mediaBusy;
    return PopScope<Object?>(
      canPop: _allowPop || !_hasSession && !controller.saving,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) unawaited(_close());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.assistantTitle),
          leading: BackButton(onPressed: _close),
          actions: [
            YamIconButton(
              icon: Icons.add_comment_outlined,
              tooltip: l10n.assistantClear,
              onPressed: disabled
                  ? null
                  : () async {
                      if (await _confirmDiscard(clearing: true) && mounted) {
                        await _clearSession();
                      }
                    },
            ),
            YamIconButton(
              key: const ValueKey('assistant-connection-settings'),
              icon: Icons.tune_rounded,
              tooltip: l10n.assistantSettings,
              onPressed: disabled ? null : _connectionSettings,
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: !_consented
              ? Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.assistantIntro,
                            style: AppTypography.sectionTitle,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(l10n.assistantPrivacy),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            l10n.assistantSessionNote,
                            style: AppTypography.label.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          YamPrimaryButton(
                            key: const ValueKey('assistant-consent'),
                            label: l10n.assistantConsent,
                            onPressed: () => setState(() => _consented = true),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: Column(
                      children: [
                        if (!connection.isConnected || connection.model == null)
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: YamPrimaryButton(
                              label: l10n.assistantNotConnected,
                              loading: connection.isLoading,
                              onPressed: _connectionSettings,
                              icon: Icons.link_rounded,
                              expanded: true,
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${connection.mode == AssistantConnectionMode.chatgpt ? l10n.assistantChatGpt : l10n.assistantApiKey} · ${connection.model}',
                                    style: AppTypography.caption,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (connection.mode ==
                                    AssistantConnectionMode.chatgpt)
                                  YamIconButton(
                                    icon: Icons.open_in_new_rounded,
                                    tooltip: l10n.assistantManageUsage,
                                    surface: false,
                                    onPressed: () async {
                                      try {
                                        await launchUrl(
                                          Uri.parse(
                                            'https://chatgpt.com/settings/usage',
                                          ),
                                          mode: LaunchMode.externalApplication,
                                        );
                                      } catch (_) {
                                        if (mounted) {
                                          setState(
                                            () => _mediaFailure = 'network',
                                          );
                                        }
                                      }
                                    },
                                  ),
                              ],
                            ),
                          ),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final draft = controller.draft;
                              final wide =
                                  constraints.maxWidth >= 1040 && draft != null;
                              final chat = ListView.builder(
                                key: const ValueKey('assistant-conversation'),
                                controller: _scroll,
                                padding: const EdgeInsets.all(AppSpacing.md),
                                itemCount:
                                    controller.messages.length +
                                    1 +
                                    (!wide && draft != null ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index < controller.messages.length) {
                                    return _message(controller.messages[index]);
                                  }
                                  if (index == controller.messages.length) {
                                    return controller.busy
                                        ? Semantics(
                                            liveRegion: true,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: AppSpacing.sm,
                                                  ),
                                              child: Text(
                                                controller.streamingText.isEmpty
                                                    ? l10n.assistantThinking
                                                    : controller.streamingText,
                                              ),
                                            ),
                                          )
                                        : controller.messages.isEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: AppSpacing.sm,
                                            ),
                                            child: Text(l10n.assistantIntro),
                                          )
                                        : const SizedBox.shrink();
                                  }
                                  return _review(draft!);
                                },
                              );
                              if (!wide) return chat;
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(child: chat),
                                  const VerticalDivider(width: 1),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.all(
                                        AppSpacing.md,
                                      ),
                                      child: _review(draft),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        if (error != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            child: Semantics(
                              liveRegion: true,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    assistantFailureText(l10n, error),
                                    style: AppTypography.label.copyWith(
                                      color: colors.error,
                                    ),
                                  ),
                                  if (controller.canRetry)
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: YamTextButton(
                                        label: l10n.assistantRetry,
                                        onPressed:
                                            connection.isConnected &&
                                                !_mediaBusy
                                            ? controller.retry
                                            : null,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        _composer(disabled),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _review(AssistantDraft draft) => AssistantDraftReview(
    key: ValueKey(draft.id),
    draft: draft,
    tools: _controller!.tools,
    disabled: _controller!.busy || _controller!.saving,
    saving: _controller!.saving,
    onChanged: _controller!.updateDraft,
    onDiscard: _controller!.dismissDraft,
    onConfirm: () async {
      final saved = await _controller!.confirm();
      if (!mounted || !saved) return;
      showYamSuccessSnackBar(
        context: context,
        message: AppLocalizations.of(context).assistantSaved,
      );
    },
  );

  Widget _message(AssistantMessage message) {
    final colors = Theme.of(context).colorScheme;
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 680),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: message.isUser ? colors.surfaceContainer : colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.image case final image?)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Image.memory(
                  image.bytes,
                  height: 160,
                  fit: BoxFit.contain,
                  semanticLabel: AppLocalizations.of(
                    context,
                  ).assistantPhotoAttached,
                ),
              ),
            if (message.text.isNotEmpty)
              SelectableText(message.text, style: AppTypography.body),
          ],
        ),
      ),
    );
  }

  Widget _composer(bool disabled) {
    final l10n = AppLocalizations.of(context);
    final controller = _controller!;
    final connected =
        widget.connection.isConnected && widget.connection.model != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_image case final image?)
              Row(
                children: [
                  Image.memory(
                    image.bytes,
                    height: AppSpacing.xxl,
                    width: AppSpacing.xxl,
                    fit: BoxFit.cover,
                    semanticLabel: l10n.assistantPhotoAttached,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      l10n.assistantPhotoAttached,
                      style: AppTypography.label,
                    ),
                  ),
                  YamIconButton(
                    icon: Icons.close_rounded,
                    tooltip: l10n.assistantRemovePhoto,
                    onPressed: disabled
                        ? null
                        : () => setState(() => _image = null),
                  ),
                ],
              ),
            if (_media.isListening)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(
                  l10n.assistantListening,
                  style: AppTypography.label,
                ),
              ),
            if (controller.messages.isEmpty)
              Row(
                children: [
                  Expanded(
                    child: YamTextButton(
                      label: MaterialLocalizations.of(
                        context,
                      ).formatMediumDate(controller.day),
                      icon: Icons.calendar_today_outlined,
                      onPressed: disabled
                          ? null
                          : () async {
                              final day = await showDatePicker(
                                context: context,
                                initialDate: controller.day,
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100, 12, 31),
                              );
                              if (day != null && mounted) {
                                setState(() => controller.day = day);
                              }
                            },
                    ),
                  ),
                  Expanded(
                    child: IgnorePointer(
                      ignoring: disabled,
                      child: YamSelectField<String>(
                        label: l10n.assistantMeal,
                        value: controller.mealId,
                        items: [
                          for (final meal in buildFoodSearchPrototypeMeals(
                            l10n,
                          ))
                            YamDropdownOption(value: meal.id, label: meal.name),
                        ],
                        onChanged: (meal) =>
                            setState(() => controller.mealId = meal),
                      ),
                    ),
                  ),
                ],
              ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.25,
              ),
              child: SingleChildScrollView(
                child: YamTextField(
                  fieldKey: const ValueKey('assistant-message-input'),
                  label: l10n.assistantPrompt,
                  hintText: l10n.assistantPromptHint,
                  controller: _input,
                  minLines: 1,
                  maxLines: 4,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact =
                    constraints.maxWidth < AppBreakpoints.navigationRail;
                final send =
                    disabled ||
                        !connected ||
                        _media.isListening ||
                        !_hasInput && _image == null
                    ? null
                    : _send;
                return Row(
                  children: [
                    YamIconButton(
                      icon: Icons.photo_outlined,
                      tooltip: l10n.assistantPhoto,
                      onPressed: disabled || _media.isListening
                          ? null
                          : () => _pickPhoto(),
                    ),
                    if (Platform.isAndroid || Platform.isIOS)
                      YamIconButton(
                        icon: Icons.photo_camera_outlined,
                        tooltip: l10n.assistantCamera,
                        onPressed: disabled || _media.isListening
                            ? null
                            : () => _pickPhoto(camera: true),
                      ),
                    YamIconButton(
                      key: const ValueKey('assistant-microphone'),
                      icon: _media.isListening
                          ? Icons.stop_circle_outlined
                          : Icons.mic_none_rounded,
                      tooltip: _media.isListening
                          ? l10n.assistantVoiceStop
                          : l10n.assistantVoice,
                      selected: _media.isListening,
                      onPressed: disabled ? null : _toggleVoice,
                    ),
                    if (_mediaBusy)
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                        ),
                        child: SizedBox.square(
                          dimension: AppSpacing.md,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    const Spacer(),
                    if (compact)
                      YamIconButton(
                        key: const ValueKey('assistant-send'),
                        icon: controller.busy
                            ? Icons.stop_rounded
                            : Icons.arrow_upward_rounded,
                        tooltip: controller.busy
                            ? l10n.assistantStop
                            : l10n.assistantSend,
                        selected: !controller.busy,
                        onPressed: controller.busy ? controller.cancel : send,
                      )
                    else if (controller.busy)
                      YamTextButton(
                        label: l10n.assistantStop,
                        onPressed: controller.cancel,
                      )
                    else
                      YamPrimaryButton(
                        key: const ValueKey('assistant-send'),
                        label: l10n.assistantSend,
                        onPressed: send,
                        icon: Icons.arrow_upward_rounded,
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
