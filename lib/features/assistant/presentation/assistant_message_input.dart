import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yam/core/ui/forms/yam_text_field.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class AssistantMessageInput extends StatelessWidget {
  const AssistantMessageInput({
    required this.controller,
    required this.focusNode,
    required this.onPasteImage,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  /// False delegates to Flutter's normal text paste; true consumes the command.
  final Future<bool> Function() onPasteImage;

  Future<void> _pasteFromMenu(EditableTextState editable) async {
    editable.hideToolbar();
    if (!await onPasteImage() && editable.mounted) {
      await editable.pasteText(SelectionChangedCause.toolbar);
    }
  }

  Widget _contextMenu(BuildContext context, EditableTextState editable) {
    final buttons = List<ContextMenuButtonItem>.of(
      editable.contextMenuButtonItems,
    );
    final paste = ContextMenuButtonItem(
      type: ContextMenuButtonType.paste,
      onPressed: () => unawaited(_pasteFromMenu(editable)),
    );
    final pasteIndex = buttons.indexWhere(
      (button) => button.type == ContextMenuButtonType.paste,
    );
    if (pasteIndex >= 0) {
      buttons[pasteIndex] = paste;
    } else {
      // Flutter checks only text availability. Image-only clipboards still need
      // Paste, without inspecting clipboard contents just to open the menu.
      final selectAllIndex = buttons.indexWhere(
        (button) => button.type == ContextMenuButtonType.selectAll,
      );
      buttons.insert(
        selectAllIndex < 0 ? buttons.length : selectAllIndex,
        paste,
      );
    }
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: editable.contextMenuAnchors,
      buttonItems: buttons,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Actions(
      actions: {
        PasteTextIntent: _PasteImageAction(
          onPasteImage: onPasteImage,
          canPasteText: () => context.mounted && focusNode.hasFocus,
        ),
      },
      child: YamTextField(
        fieldKey: const ValueKey('assistant-message-input'),
        label: l10n.assistantPrompt,
        hintText: l10n.assistantPromptHint,
        controller: controller,
        focusNode: focusNode,
        embedded: true,
        minLines: 1,
        maxLines: 4,
        contextMenuBuilder: _contextMenu,
      ),
    );
  }
}

class _PasteImageAction extends Action<PasteTextIntent> {
  _PasteImageAction({required this.onPasteImage, required this.canPasteText});

  final Future<bool> Function() onPasteImage;
  final bool Function() canPasteText;

  @override
  Object? invoke(PasteTextIntent intent) {
    // callingAction is set only during this invocation; retain the default
    // action before awaiting native clipboard access.
    return _paste(intent, callingAction);
  }

  Future<void> _paste(
    PasteTextIntent intent,
    Action<PasteTextIntent>? textPaste,
  ) async {
    if (!await onPasteImage() && canPasteText()) {
      textPaste?.invoke(intent);
    }
  }
}
