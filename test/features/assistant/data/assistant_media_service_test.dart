import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:yam/features/assistant/data/assistant_media_service.dart';
import 'package:yam/features/assistant/domain/assistant_models.dart';

class _ImageSelection extends FilePicker {
  _ImageSelection(this.file);
  final PlatformFile file;
  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = false,
    int compressionQuality = 0,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async => FilePickerResult([file]);
}

void main() {
  late AssistantMediaService media;
  FilePicker? previous;
  setUp(() {
    try {
      previous = FilePicker.platform;
    } catch (_) {
      previous = null;
    }
    media = AssistantMediaService();
  });
  tearDown(() async {
    await media.dispose();
    FilePicker.platform = previous ?? FilePickerIO();
  });

  test(
    'camera orientation survives while EXIF identity is removed before upload',
    () async {
      final source = image.Image(width: 4, height: 2);
      source.exif.imageIfd['Orientation'] = 6;
      source.exif.imageIfd['Artist'] = 'private-camera-owner';
      final encoded = image.encodeJpg(source);
      FilePicker.platform = _ImageSelection(
        PlatformFile(
          name: 'food.jpg',
          size: encoded.length,
          readStream: Stream.value(encoded),
        ),
      );
      final selected = (await media.pickImage())!;
      final decoded = image.decodeImage(selected.bytes)!;
      expect(selected.mimeType, 'image/jpeg');
      expect((decoded.width, decoded.height), (2, 4));
      expect(decoded.exif.imageIfd.isEmpty, isTrue);
      expect(decoded.exif.exifIfd.isEmpty, isTrue);
      expect(decoded.exif.gpsIfd.isEmpty, isTrue);
      expect(decoded.textData, isNull);
    },
  );

  test('stream size limit cannot be bypassed by a false picker size', () async {
    FilePicker.platform = _ImageSelection(
      PlatformFile(
        name: 'food.jpg',
        size: 1,
        readStream: Stream.fromIterable([
          Uint8List(10 * 1024 * 1024),
          Uint8List.fromList([1]),
        ]),
      ),
    );
    await expectLater(
      media.pickImage(),
      throwsA(
        isA<AssistantFailure>().having(
          (error) => error.code,
          'code',
          'image_too_large',
        ),
      ),
    );
  });
}
