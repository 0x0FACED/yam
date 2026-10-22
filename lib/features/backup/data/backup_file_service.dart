import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:yam/features/backup/data/backup_repository.dart';

/// Native dialogs and bounded file reads, replaceable in an embedded host.
class BackupFileService {
  const BackupFileService();

  /// Returns null when the user dismisses the open dialog.
  Future<Uint8List?> openBackup({required String dialogTitle}) async {
    final selected = await FilePicker.platform.pickFiles(
      dialogTitle: dialogTitle,
      type: FileType.any,
      allowMultiple: false,
      withData: false,
      withReadStream: true,
    );
    if (selected == null) return null;
    final file = selected.files.single;

    if (file.size > maxBackupFileBytes) {
      throw const BackupException(BackupFailure.tooLarge);
    }
    final stream =
        file.readStream ??
        (file.path == null ? null : File(file.path!).openRead());
    if (stream == null) {
      throw const FileSystemException('The selected file cannot be read.');
    }

    final bytes = BytesBuilder(copy: false);
    var total = 0;
    await for (final chunk in stream) {
      total += chunk.length;
      if (total > maxBackupFileBytes) {
        // Leaving await-for cancels the subscription before retaining the chunk.
        throw const BackupException(BackupFailure.tooLarge);
      }
      bytes.add(chunk);
    }
    return bytes.takeBytes();
  }

  /// Returns false when the user dismisses the save dialog, not on write errors.
  Future<bool> saveBackup(
    Uint8List bytes, {
    required String fileName,
    required String dialogTitle,
  }) async {
    if (bytes.length > maxBackupFileBytes) {
      throw const BackupException(BackupFailure.tooLarge);
    }
    final saved = await FilePicker.platform.saveFile(
      fileName: fileName,
      bytes: bytes,
      dialogTitle: dialogTitle,
      type: FileType.any,
    );
    return saved != null;
  }
}
