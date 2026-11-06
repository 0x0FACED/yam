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
import 'package:yam/core/ui/feedback/yam_snack_bar.dart';
import 'package:yam/core/ui/selection/yam_dropdown.dart';
import 'package:yam/features/assistant/application/assistant_controller.dart';
import 'package:yam/features/assistant/application/assistant_tools.dart';
import 'package:yam/features/assistant/data/assistant_connection_manager.dart';
import 'package:yam/features/assistant/data/assistant_media_service.dart';
import 'package:yam/features/assistant/domain/assistant_models.dart';
import 'package:yam/features/assistant/presentation/assistant_draft_review.dart';
import 'package:yam/features/assistant/presentation/assistant_history_screen.dart';
import 'package:yam/features/assistant/presentation/assistant_failure_text.dart';
import 'package:yam/features/assistant/presentation/assistant_message_bubble.dart';
import 'package:yam/features/assistant/presentation/assistant_message_input.dart';
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
  final _inputFocus = FocusNode();
  final _scroll = ScrollController();
  late final AssistantMediaService _media;
  AssistantController? _controller;
  AssistantImage? _image;
  String? _mediaFailure;
  bool _mediaBusy = false;
  bool _allowPop = false;
  bool _closePromptOpen = false;
  bool _hasInput = false;
  bool _followTail = true;
  bool _tailScrollPending = false;
  bool _scrollingToTail = false;

  @override
  void initState() {
    super.initState();
    _media = AssistantMediaService(
      transcribe: widget.connection.transcribe,
      canTranscribe: () => widget.connection.hasApiKey,
    );
    widget.connection.addListener(_changed);
    _input.addListener(_inputChanged);
    _inputFocus.addListener(_changed);
    _scroll.addListener(_scrollChanged);
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
      savedNote: AppLocalizations.of(context).assistantSaved,
      discardedNote: AppLocalizations.of(context).assistantDraftDiscarded,
    )..addListener(_changed);
  }

  void _inputChanged() {
    final hasInput = _input.text.trim().isNotEmpty;
    if (_hasInput == hasInput) return;
    _hasInput = hasInput;
    if (mounted) setState(() {});
  }

  void _changed() {
    if (!mounted) return;
    setState(() {});
    _scheduleTailScroll();
  }

  void _scrollChanged() {
    if (_scrollingToTail || !_scroll.hasClients) return;
    final position = _scroll.position;
    if (position.hasContentDimensions) {
      _followTail = position.extentAfter <= 1;
    }
  }

  void _scheduleTailScroll() {
    if (!mounted || !_followTail || _tailScrollPending) return;
    _tailScrollPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tailScrollPending = false;
      if (!mounted || !_followTail || !_scroll.hasClients) return;
      final position = _scroll.position;
      if (!position.hasContentDimensions || position.extentAfter <= 0) return;
      _scrollingToTail = true;
      try {
        position.jumpTo(position.maxScrollExtent);
      } finally {
        _scrollingToTail = false;
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  bool get _hasSession =>
      _hasInput ||
      _image != null ||
      _controller?.busy == true ||
      _controller?.storageDirty == true ||
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
    if (!await _controller!.flush() || !mounted) return;
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
    if (!mounted || _controller!.storageDirty) return;
    await context.push('/assistant/connection');
  }

  Future<void> _openHistory() async {
    if (!await _confirmDiscard() || !mounted) return;
    if (!await _controller!.flush() || !mounted) return;
    final id = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) =>
            AssistantHistoryScreen(repository: _controller!.conversations),
      ),
    );
    if (!mounted) return;
    try {
      if (_controller!.messages.isNotEmpty &&
          await _controller!.conversations.load(_controller!.conversationId) ==
              null) {
        if (!mounted) return;
        await _clearSession(persist: false);
      }
      if (id == null) return;
      final conversation = await _controller!.conversations.load(id);
      if (!mounted || conversation == null) return;
      await _clearSession(persist: false);
      if (!mounted) return;
      _controller!.restore(conversation);
    } catch (_) {
      if (mounted) setState(() => _mediaFailure = 'history_storage');
    }
  }

  Future<void> _clearSession({bool persist = true}) async {
    if (persist && (!await _controller!.flush() || !mounted)) return;
    await _media.cancelSpeech();
    if (!mounted) return;
    _followTail = true;
    _controller?.clear();
    _controller!.day = widget.day;
    _controller!.mealId = widget.mealId;
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

  Future<bool> _pastePhoto() async {
    if (!mounted) return true;
    final controller = _controller!;
    if (controller.busy ||
        controller.saving ||
        _mediaBusy ||
        _media.isListening) {
      return false;
    }
    setState(() => _mediaBusy = true);
    try {
      final image = await _media.pasteImage();
      if (!mounted) return true;
      if (image == null) return false;
      setState(() {
        _image = image;
        _mediaFailure = null;
      });
    } on AssistantFailure catch (failure) {
      if (mounted) setState(() => _mediaFailure = failure.code);
    } catch (_) {
      if (mounted) setState(() => _mediaFailure = 'media_failed');
    } finally {
      if (mounted) setState(() => _mediaBusy = false);
    }
    return true;
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
    _inputFocus.dispose();
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
          title: Text(
            l10n.assistantTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: BackButton(onPressed: _close),
          actions: [
            const SizedBox(width: AppSpacing.xs),
            YamIconButton(
              key: const ValueKey('assistant-history'),
              icon: Icons.history_rounded,
              tooltip: l10n.assistantHistory,
              surface: false,
              onPressed: disabled ? null : _openHistory,
            ),
            const SizedBox(width: AppSpacing.xs),
            YamIconButton(
              icon: Icons.add_comment_outlined,
              tooltip: l10n.assistantClear,
              surface: false,
              onPressed: disabled
                  ? null
                  : () async {
                      if (await _confirmDiscard(clearing: true) && mounted) {
                        await _clearSession();
                      }
                    },
            ),
            const SizedBox(width: AppSpacing.xs),
            YamIconButton(
              key: const ValueKey('assistant-connection-settings'),
              icon: Icons.tune_rounded,
              tooltip: l10n.assistantSettings,
              surface: false,
              onPressed: disabled ? null : _connectionSettings,
            ),
            const SizedBox(width: AppSpacing.md),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: controller.draft == null ? 720 : 1120,
              ),
              child: Column(
                children: [
                  if (MediaQuery.viewInsetsOf(context).bottom == 0) ...[
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
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.xs,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${connection.mode == AssistantConnectionMode.chatgpt ? l10n.assistantChatGpt : l10n.assistantApiKey} · ${connection.model}',
                                style: AppTypography.caption.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
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
                                      setState(() => _mediaFailure = 'network');
                                    }
                                  }
                                },
                              ),
                          ],
                        ),
                      ),
                  ],
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, viewport) => Column(
                        children: [
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final draft = controller.draft;
                                final wide =
                                    constraints.maxWidth >= 1040 &&
                                    draft != null;
                                final chat = NotificationListener<ScrollMetricsNotification>(
                                  onNotification: (notification) {
                                    if (notification.depth == 0) {
                                      _scheduleTailScroll();
                                    }
                                    return false;
                                  },
                                  child: ListView.builder(
                                    key: const ValueKey(
                                      'assistant-conversation',
                                    ),
                                    controller: _scroll,
                                    keyboardDismissBehavior:
                                        ScrollViewKeyboardDismissBehavior
                                            .onDrag,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          constraints.maxWidth <
                                              AppBreakpoints.navigationRail
                                          ? AppSpacing.md
                                          : AppSpacing.lg,
                                      vertical: controller.messages.isEmpty
                                          ? AppSpacing.xs
                                          : AppSpacing.lg,
                                    ),
                                    itemCount:
                                        controller.messages.length +
                                        1 +
                                        (!wide && draft != null ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index < controller.messages.length) {
                                        return AssistantMessageBubble(
                                          message: controller.messages[index],
                                        );
                                      }
                                      if (index == controller.messages.length) {
                                        return controller.busy
                                            ? Semantics(
                                                liveRegion: true,
                                                child:
                                                    controller
                                                        .streamingText
                                                        .isEmpty
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              AppSpacing.md,
                                                            ),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .auto_awesome_outlined,
                                                              size: 18,
                                                              color: colors
                                                                  .primary,
                                                            ),
                                                            const SizedBox(
                                                              width:
                                                                  AppSpacing.sm,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                l10n.assistantThinking,
                                                                style: AppTypography
                                                                    .body
                                                                    .copyWith(
                                                                      color: colors
                                                                          .onSurfaceVariant,
                                                                    ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : AssistantMessageBubble(
                                                        message:
                                                            AssistantMessage(
                                                              isUser: false,
                                                              text: controller
                                                                  .streamingText,
                                                            ),
                                                      ),
                                              )
                                            : const SizedBox.shrink();
                                      }
                                      return _review(draft!);
                                    },
                                  ),
                                );
                                if (!wide) return chat;
                                return Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
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
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: viewport.maxHeight * 0.25,
                              ),
                              child: SingleChildScrollView(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.xs,
                                  ),
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: colors.errorContainer,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.control,
                                    ),
                                  ),
                                  child: Semantics(
                                    liveRegion: true,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          assistantFailureText(l10n, error),
                                          style: AppTypography.label.copyWith(
                                            color: colors.onErrorContainer,
                                          ),
                                        ),
                                        if (controller.canRetry)
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: YamTextButton(
                                              label: l10n.assistantRetry,
                                              onPressed:
                                                  !controller.busy &&
                                                      !controller.saving &&
                                                      !_mediaBusy &&
                                                      (controller
                                                              .storageDirty ||
                                                          connection
                                                              .isConnected)
                                                  ? controller.retry
                                                  : null,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight:
                                  viewport.maxHeight *
                                  (error == null ? 1 : 0.75),
                            ),
                            child: _composer(
                              disabled,
                              inlineContext:
                                  viewport.maxWidth >=
                                  600 *
                                      MediaQuery.textScalerOf(context).scale(1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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

  Widget _composer(bool disabled, {required bool inlineContext}) {
    final l10n = AppLocalizations.of(context);
    final controller = _controller!;
    final connected =
        widget.connection.isConnected && widget.connection.model != null;
    final colors = Theme.of(context).colorScheme;
    final showContext =
        controller.messages.isEmpty &&
        MediaQuery.viewInsetsOf(context).bottom == 0;
    final send =
        disabled ||
            !connected ||
            _media.isListening ||
            !_hasInput && _image == null
        ? null
        : _send;
    return Container(
      key: const ValueKey('assistant-composer'),
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xxs,
        AppSpacing.md,
        AppSpacing.md,
      ),
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(
          color: _inputFocus.hasFocus ? colors.primary : colors.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (controller.hasArchivedContext)
                    SwitchListTile.adaptive(
                      key: const ValueKey('assistant-use-history'),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                      ),
                      title: Text(
                        l10n.assistantUseHistory,
                        style: AppTypography.label,
                      ),
                      subtitle: Text(
                        controller.useArchivedContext
                            ? l10n.assistantUseHistoryNote
                            : l10n.assistantHistoryOffNote,
                        style: AppTypography.caption,
                      ),
                      value: controller.useArchivedContext,
                      onChanged: disabled
                          ? null
                          : controller.setUseArchivedContext,
                    ),
                  if (showContext && !inlineContext)
                    _contextSelectors(disabled),
                  if (_image case final image?)
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppRadius.small,
                            ),
                            child: Image.memory(
                              image.bytes,
                              height: AppSpacing.xxl,
                              width: AppSpacing.xxl,
                              fit: BoxFit.cover,
                              semanticLabel: l10n.assistantPhotoAttached,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(child: Text(l10n.assistantPhotoAttached)),
                          YamIconButton(
                            icon: Icons.close_rounded,
                            tooltip: l10n.assistantRemovePhoto,
                            surface: false,
                            onPressed: disabled
                                ? null
                                : () => setState(() => _image = null),
                          ),
                        ],
                      ),
                    ),
                  if (_media.isListening)
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      child: Text(
                        l10n.assistantListening,
                        style: AppTypography.label,
                      ),
                    ),
                  AssistantMessageInput(
                    controller: _input,
                    focusNode: _inputFocus,
                    onPasteImage: _pastePhoto,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Row(
            children: [
              YamIconButton(
                icon: Icons.photo_outlined,
                tooltip: l10n.assistantPhoto,
                surface: false,
                onPressed: disabled || _media.isListening
                    ? null
                    : () => _pickPhoto(),
              ),
              const SizedBox(width: AppSpacing.xs),
              if (Platform.isAndroid || Platform.isIOS) ...[
                YamIconButton(
                  icon: Icons.photo_camera_outlined,
                  tooltip: l10n.assistantCamera,
                  surface: false,
                  onPressed: disabled || _media.isListening
                      ? null
                      : () => _pickPhoto(camera: true),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              YamIconButton(
                key: const ValueKey('assistant-microphone'),
                icon: _media.isListening
                    ? Icons.stop_circle_outlined
                    : Icons.mic_none_rounded,
                tooltip: _media.isListening
                    ? l10n.assistantVoiceStop
                    : l10n.assistantVoice,
                surface: false,
                selected: _media.isListening,
                onPressed: disabled ? null : _toggleVoice,
              ),
              if (_mediaBusy)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  child: SizedBox.square(
                    dimension: AppSpacing.md,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              if (showContext && inlineContext) ...[
                const SizedBox(width: AppSpacing.md),
                _contextSelectors(disabled),
              ],
              const Spacer(),
              YamIconButton(
                key: const ValueKey('assistant-send'),
                icon: controller.busy
                    ? Icons.stop_rounded
                    : Icons.arrow_upward_rounded,
                tooltip: controller.busy
                    ? l10n.assistantStop
                    : l10n.assistantSend,
                surface: false,
                selected: !controller.busy && send != null,
                onPressed: controller.busy ? controller.cancel : send,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contextSelectors(bool disabled) {
    final l10n = AppLocalizations.of(context);
    final controller = _controller!;
    final colors = Theme.of(context).colorScheme;
    final meals = buildFoodSearchPrototypeMeals(l10n);
    final meal = meals.firstWhere((meal) => meal.id == controller.mealId);
    return Wrap(
      spacing: AppSpacing.xs,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: YamTextButton(
            key: const ValueKey('assistant-day'),
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
        YamDropdown<String>(
          value: controller.mealId,
          options: [
            for (final meal in meals)
              YamDropdownOption(value: meal.id, label: meal.name),
          ],
          onSelected: (meal) => setState(() => controller.mealId = meal),
          triggerBuilder: (context, toggle, focusNode, isOpen) => Tooltip(
            message: l10n.assistantMeal,
            child: TextButton(
              key: const ValueKey('assistant-meal'),
              focusNode: focusNode,
              onPressed: disabled ? null : toggle,
              style: TextButton.styleFrom(
                minimumSize: const Size(44, 44),
                visualDensity: VisualDensity.standard,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                foregroundColor: colors.onSurfaceVariant,
                textStyle: AppTypography.label,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(meal.name),
                  const SizedBox(width: AppSpacing.xxs),
                  Icon(
                    isOpen
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
