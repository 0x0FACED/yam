import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yam/app/theme/app_elevation.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_breakpoints.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';
import 'package:yam/core/ui/buttons/yam_floating_actions.dart';
import 'package:yam/core/ui/layout/yam_floating_layout.dart';
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
import 'package:yam/features/assistant/presentation/assistant_thinking_indicator.dart';
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
  final _reviewKey = GlobalKey();
  late final AssistantMediaService _media;
  AssistantController? _controller;
  AssistantImage? _image;
  String? _mediaFailure;
  bool _mediaBusy = false;
  bool _allowPop = false;
  bool _transitioning = false;
  bool _hasInput = false;
  bool _followTail = true;
  bool _tailScrollPending = false;
  bool _scrollingToTail = false;
  String? _reviewDraftId;
  final Set<String> _invalidDraftAmounts = {};

  @override
  void initState() {
    super.initState();
    _media = AssistantMediaService(
      transcribe: widget.connection.transcribe,
      canTranscribe: () => widget.connection.hasApiKey,
    );
    widget.connection.addListener(_changed);
    _input.addListener(_inputChanged);
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
    final draft = _controller?.draft;
    if (_reviewDraftId != draft?.id) {
      _reviewDraftId = draft?.id;
      _invalidDraftAmounts.clear();
    } else {
      _invalidDraftAmounts.removeWhere(
        (id) => draft == null || !draft.items.any((item) => item.id == id),
      );
    }
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
              YamTextButton(
                label: l10n.assistantKeepEditing,
                onPressed: () => Navigator.pop(context, false),
              ),
              YamTextButton(
                label: switching
                    ? l10n.backupDone
                    : clearing
                    ? l10n.assistantClear
                    : l10n.assistantCloseConfirm,
                tone: switching
                    ? YamTextButtonTone.accent
                    : YamTextButtonTone.destructive,
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _transition(Future<void> Function() action) async {
    if (_transitioning || _controller!.saving || _mediaBusy) return;
    setState(() => _transitioning = true);
    _inputFocus.unfocus();
    try {
      await action();
    } finally {
      if (mounted) setState(() => _transitioning = false);
    }
  }

  Future<void> _close() => _transition(() async {
    if (!await _confirmDiscard() || !mounted) return;
    _controller!.cancel();
    await _media.cancelSpeech();
    if (!await _controller!.flush() || !mounted) return;
    setState(() => _allowPop = true);
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) context.pop();
  });

  Future<void> _connectionSettings() => _transition(() async {
    if (!await _confirmDiscard(switching: true) || !mounted) return;
    await _clearSession();
    if (!mounted || _controller!.storageDirty) return;
    await context.push('/assistant/connection');
  });

  Future<void> _newConversation() => _transition(() async {
    if (await _confirmDiscard(clearing: true) && mounted) {
      await _clearSession();
    }
  });

  Future<void> _openHistory() => _transition(() async {
    if (!await _confirmDiscard() || !mounted) return;
    _controller!.cancel();
    await _media.cancelSpeech();
    if (!mounted) return;
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
  });

  Future<void> _clearSession({bool persist = true}) async {
    _controller?.cancel();
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
    if (_transitioning ||
        controller.busy ||
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
    if (_transitioning || _mediaBusy || _controller!.saving) return;
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
    if (_transitioning ||
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
    if (_transitioning || _mediaBusy || _controller!.saving) return;
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
    final disabled = _transitioning || controller.saving || _mediaBusy;
    return PopScope<Object?>(
      canPop: _allowPop || !_hasSession && !disabled,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) unawaited(_close());
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: math.max(
            kToolbarHeight,
            MediaQuery.textScalerOf(
                      context,
                    ).scale(AppTypography.screenTitle.fontSize!) *
                    AppTypography.screenTitle.height! +
                MediaQuery.textScalerOf(
                      context,
                    ).scale(AppTypography.caption.fontSize!) *
                    AppTypography.caption.height! +
                AppSpacing.sm,
          ),
          titleSpacing: AppSpacing.xxs,
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.appName, maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(
                connection.isConnected && connection.model != null
                    ? '${connection.mode == AssistantConnectionMode.chatgpt ? l10n.assistantChatGpt : l10n.assistantApiKey} · ${connection.model}'
                    : l10n.assistantNotConnected,
                style: AppTypography.caption.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          leading: BackButton(onPressed: _close),
          actions: [
            YamIconButton(
              key: const ValueKey('assistant-history'),
              icon: Icons.history_rounded,
              tooltip: l10n.assistantHistory,
              surface: false,
              onPressed: disabled ? null : _openHistory,
            ),
            YamIconButton(
              icon: Icons.add_comment_outlined,
              tooltip: l10n.assistantClear,
              surface: false,
              onPressed: disabled ? null : _newConversation,
            ),
            YamIconButton(
              key: const ValueKey('assistant-connection-settings'),
              icon: Icons.tune_rounded,
              tooltip: l10n.assistantSettings,
              surface: false,
              onPressed: disabled ? null : _connectionSettings,
            ),
            const SizedBox(width: AppSpacing.xs),
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
              child: LayoutBuilder(
                builder: (context, viewport) {
                  final draft = controller.draft;
                  final wide = viewport.maxWidth >= 1040 && draft != null;
                  return YamFloatingLayout(
                    inset: AppSpacing.xxs,
                    contentBuilder: (context, bottomClearance) {
                      final chat = _conversation(
                        bottomClearance,
                        wide: wide,
                        width: wide ? viewport.maxWidth / 2 : viewport.maxWidth,
                      );
                      if (!wide) return chat;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: chat),
                          const VerticalDivider(width: 1),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.fromLTRB(
                                AppSpacing.md,
                                AppSpacing.md,
                                AppSpacing.md,
                                bottomClearance,
                              ),
                              child: _review(draft),
                            ),
                          ),
                        ],
                      );
                    },
                    floating: wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (error != null) _error(error),
                                    _composer(disabled, inlineContext: false),
                                  ],
                                ),
                              ),
                              Expanded(child: _draftActions(draft, disabled)),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (error != null) _error(error),
                              if (draft != null) _draftActions(draft, disabled),
                              _composer(
                                disabled,
                                inlineContext:
                                    viewport.maxWidth >=
                                    600 *
                                        MediaQuery.textScalerOf(
                                          context,
                                        ).scale(1),
                              ),
                            ],
                          ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _conversation(
    double bottomClearance, {
    required bool wide,
    required double width,
  }) {
    final controller = _controller!;
    final draft = controller.draft;
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (notification) {
        if (notification.depth == 0) _scheduleTailScroll();
        return false;
      },
      child: ListView.builder(
        key: const ValueKey('assistant-conversation'),
        controller: _scroll,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          width < AppBreakpoints.navigationRail ? AppSpacing.md : AppSpacing.lg,
          controller.messages.isEmpty ? AppSpacing.xs : AppSpacing.lg,
          width < AppBreakpoints.navigationRail ? AppSpacing.md : AppSpacing.lg,
          bottomClearance,
        ),
        itemCount:
            controller.messages.length + 1 + (!wide && draft != null ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < controller.messages.length) {
            return AssistantMessageBubble(message: controller.messages[index]);
          }
          if (index == controller.messages.length) {
            return controller.busy
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AssistantThinkingIndicator(),
                      if (controller.streamingText.isNotEmpty)
                        AssistantMessageBubble(
                          message: AssistantMessage(
                            isUser: false,
                            text: controller.streamingText,
                          ),
                        ),
                    ],
                  )
                : const SizedBox.shrink();
          }
          return _review(draft!);
        },
      ),
    );
  }

  Widget _error(String error) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final controller = _controller!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.xs,
      ),
      child: Material(
        key: const ValueKey('assistant-error'),
        color: colors.errorContainer,
        elevation: AppElevation.floatingAction,
        shadowColor: AppElevation.floatingShadow(colors),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.small)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Semantics(
            liveRegion: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          !_transitioning &&
                              !controller.saving &&
                              !_mediaBusy &&
                              (controller.storageDirty ||
                                  widget.connection.isConnected)
                          ? controller.retry
                          : null,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _draftActions(AssistantDraft draft, bool disabled) {
    final l10n = AppLocalizations.of(context);
    final valid =
        draft.items.isNotEmpty &&
        _invalidDraftAmounts.isEmpty &&
        draft.items.every(
          (item) =>
              item.addToDiary || item.newFood != null && item.saveToCatalog,
        );
    return YamFloatingActions(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          YamPrimaryButton(
            key: const ValueKey('assistant-confirm-draft'),
            label: draft.hasDiaryItems
                ? l10n.assistantAddToDiary
                : l10n.assistantSaveProducts,
            expanded: true,
            loading: _controller!.saving,
            onPressed: disabled || _controller!.busy || !valid
                ? null
                : _confirmDraft,
          ),
          const SizedBox(height: AppSpacing.xs),
          YamTextButton(
            label: l10n.assistantDiscard,
            onPressed: disabled || _controller!.busy
                ? null
                : _controller!.dismissDraft,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDraft() async {
    final saved = await _controller!.confirm();
    if (!mounted || !saved) return;
    showYamSuccessSnackBar(
      context: context,
      message: AppLocalizations.of(context).assistantSaved,
    );
  }

  Widget _review(AssistantDraft draft) => AssistantDraftReview(
    key: _reviewKey,
    draft: draft,
    tools: _controller!.tools,
    disabled: _transitioning || _controller!.busy || _controller!.saving,
    invalidAmounts: _invalidDraftAmounts,
    onAmountValidityChanged: (id, valid) => setState(() {
      if (valid) {
        _invalidDraftAmounts.remove(id);
      } else {
        _invalidDraftAmounts.add(id);
      }
    }),
    onChanged: _controller!.updateDraft,
  );

  Widget _composer(bool disabled, {required bool inlineContext}) {
    final l10n = AppLocalizations.of(context);
    final controller = _controller!;
    final connected =
        widget.connection.isConnected && widget.connection.model != null;
    final colors = Theme.of(context).colorScheme;
    // Keep context controls mounted while the keyboard changes the viewport.
    // Scaffold is the sole owner of keyboard insets; do not tween them again.
    final send =
        controller.busy ||
            disabled ||
            !connected ||
            _media.isListening ||
            !_hasInput && _image == null
        ? null
        : _send;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.xxs,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Material(
        key: const ValueKey('assistant-composer'),
        color: colors.surfaceContainerLow,
        elevation: AppElevation.floatingAction,
        shadowColor: AppElevation.floatingShadow(colors),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.small)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (controller.hasArchivedContext)
                    SwitchListTile(
                      key: const ValueKey('assistant-use-history'),
                      dense: true,
                      inactiveThumbColor: colors.onSurfaceVariant,
                      inactiveTrackColor: colors.surfaceContainerHighest,
                      activeThumbColor: colors.onPrimary,
                      activeTrackColor: colors.primary,
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
                  if (!inlineContext) _contextSelectors(disabled),
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
                  AbsorbPointer(
                    absorbing: _transitioning,
                    child: AssistantMessageInput(
                      controller: _input,
                      focusNode: _inputFocus,
                      onPasteImage: _pastePhoto,
                    ),
                  ),
                ],
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
                  if (Platform.isAndroid || Platform.isIOS) ...[
                    YamIconButton(
                      icon: Icons.photo_camera_outlined,
                      tooltip: l10n.assistantCamera,
                      surface: false,
                      onPressed: disabled || _media.isListening
                          ? null
                          : () => _pickPhoto(camera: true),
                    ),
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
                  if (inlineContext) ...[
                    const SizedBox(width: AppSpacing.xxs),
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
        ),
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
          onSelected: disabled
              ? null
              : (meal) => setState(() => controller.mealId = meal),
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
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppRadius.small),
                  ),
                ),
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
