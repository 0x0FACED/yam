import 'package:flutter/material.dart';

void showYamUndoSnackBar({
  required BuildContext context,
  required String message,
  required String undoLabel,
  required VoidCallback onUndo,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(label: undoLabel, onPressed: onUndo),
      ),
    );
}
