import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:yam/features/food_library/data/food_library_repository.dart';

class FoodLibraryFileService {
  const FoodLibraryFileService();

  Future<Uint8List?> openLibrary({required String dialogTitle}) async {
    final selected = await FilePicker.platform.pickFiles(
      dialogTitle: dialogTitle,
      type: FileType.any,
      allowMultiple: false,
      withData: false,
      withReadStream: true,
    );
    if (selected == null) return null;
    final file = selected.files.single;
    if (file.size > maxFoodLibraryFileBytes) {
      throw const FoodLibraryException(FoodLibraryFailure.tooLarge);
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
      if (total > maxFoodLibraryFileBytes) {
        throw const FoodLibraryException(FoodLibraryFailure.tooLarge);
      }
      bytes.add(chunk);
    }
    return bytes.takeBytes();
  }

  Future<bool> saveLibrary(
    Uint8List bytes, {
    required String fileName,
    required String dialogTitle,
  }) async {
    if (bytes.length > maxFoodLibraryFileBytes) {
      throw const FoodLibraryException(FoodLibraryFailure.tooLarge);
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
