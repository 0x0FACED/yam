import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;
import 'package:image_picker/image_picker.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as speech;
import 'package:yam/features/assistant/domain/assistant_models.dart';

const _maxImageBytes = 10 * 1024 * 1024;
const _maxImagePixels = 24 * 1024 * 1024;
const _sampleRate = 16000;
const _maxAudioBytes = _sampleRate * 2 * 60;

/// Media is acquired only after an explicit action. Recognition only edits text;
/// neither speech results nor images submit an assistant request automatically.
class AssistantMediaService {
  AssistantMediaService({
    Future<String> Function(
      Uint8List bytes, {
      required String filename,
      required String mimeType,
    })?
    transcribe,
    bool Function()? canTranscribe,
    Future<Uint8List?> Function()? readClipboardImage,
  }) : _transcribe = transcribe,
       _canTranscribe = canTranscribe,
       _readClipboardImage = readClipboardImage ?? _clipboardImage;

  // speech_to_text is a singleton and retains its initial callbacks. Route them
  // to the current screen rather than retaining a disposed service on reopening.
  static final _speech = speech.SpeechToText();
  static AssistantMediaService? _speechOwner;

  static Future<Uint8List?> _clipboardImage() => Pasteboard.image;

  final Future<Uint8List?> Function() _readClipboardImage;
  final Future<String> Function(
    Uint8List bytes, {
    required String filename,
    required String mimeType,
  })?
  _transcribe;
  final bool Function()? _canTranscribe;
  AudioRecorder? _recorder;
  StreamSubscription<Uint8List>? _audioSubscription;
  BytesBuilder? _audio;
  Timer? _recordingLimit;
  Future<void>? _starting;
  Future<void>? _stopping;
  void Function(String)? _onText;
  void Function(String)? _onError;
  void Function(bool)? _onListeningChanged;
  bool _disposed = false;
  bool _listening = false;
  bool _recording = false;
  bool _nativeStarting = false;
  Completer<bool>? _nativeReady;
  String? _nativeFailure;
  int _generation = 0;

  bool get isListening => _listening;
  bool get _hasTranscription =>
      _transcribe != null && (_canTranscribe?.call() ?? true);
  bool _isCurrent(int generation) => !_disposed && generation == _generation;

  void _setListening(bool value) {
    if (_listening == value) return;
    _listening = value;
    if (!_disposed) _onListeningChanged?.call(value);
  }

  Future<void> startSpeech({
    required String locale,
    required void Function(String) onText,
    required void Function(String code) onError,
    void Function(bool listening)? onListeningChanged,
  }) async {
    if (_disposed) throw const AssistantFailure('media_unavailable');
    if (_starting != null || _stopping != null || _listening) {
      throw const AssistantFailure('speech_busy');
    }
    final generation = ++_generation;
    _nativeFailure = null;
    _onText = onText;
    _onError = onError;
    _onListeningChanged = onListeningChanged;
    final operation = _startSpeech(locale, generation);
    _starting = operation;
    try {
      await operation;
    } on AssistantFailure {
      rethrow;
    } catch (_) {
      if (_isCurrent(generation)) {
        throw const AssistantFailure('speech_unavailable');
      }
    } finally {
      _starting = null;
    }
  }

  Future<void> _startSpeech(String locale, int generation) async {
    if (!Platform.isLinux) {
      _speechOwner = this;
      _nativeStarting = true;
      try {
        final available = await _speech.initialize(
          onStatus: (status) => _speechOwner?._nativeStatus(status),
          onError: (error) => _speechOwner?._nativeError(error.errorMsg),
          options: [speech.SpeechToText.androidNoBluetooth],
        );
        if (!_isCurrent(generation)) return;
        if (available) {
          final locales = await _speech.locales();
          if (!_isCurrent(generation)) return;
          final normalized = locale.replaceAll('-', '_').toLowerCase();
          String? localeId;
          for (final candidate in locales) {
            if (candidate.localeId.replaceAll('-', '_').toLowerCase() ==
                normalized) {
              localeId = candidate.localeId;
              break;
            }
          }
          if (localeId == null) {
            final language = normalized.split('_').first;
            for (final candidate in locales) {
              if (candidate.localeId
                      .replaceAll('-', '_')
                      .toLowerCase()
                      .split('_')
                      .first ==
                  language) {
                localeId = candidate.localeId;
                break;
              }
            }
          }
          // Do not silently recognize Russian as the device's English locale.
          if (localeId != null) {
            final ready = Completer<bool>();
            _nativeReady = ready;
            await _speech.listen(
              localeId: localeId,
              listenFor: const Duration(seconds: 60),
              pauseFor: const Duration(seconds: 5),
              listenOptions: speech.SpeechListenOptions(
                cancelOnError: true,
                partialResults: true,
                listenMode: speech.ListenMode.dictation,
              ),
              onResult: (result) {
                if (_isCurrent(generation) && !_recording) {
                  _onText?.call(result.recognizedWords);
                }
              },
            );
            final started = await ready.future.timeout(
              const Duration(seconds: 3),
              onTimeout: () => _speech.isListening,
            );
            if (!_isCurrent(generation)) {
              await _speech.cancel();
              return;
            }
            if (started && _nativeFailure == null) return;
          }
        }
      } catch (_) {
        // An unavailable native recognizer can use API ASR, never a fake result.
      } finally {
        _nativeStarting = false;
        _nativeReady = null;
      }
      try {
        await _speech.cancel();
      } catch (_) {
        // A failed native plugin must not prevent the API recording fallback.
      }
      if (!_isCurrent(generation)) return;
    }
    if (!_hasTranscription) {
      throw AssistantFailure(
        Platform.isLinux
            ? 'speech_requires_api_key'
            : (_nativeFailure ?? 'speech_unavailable'),
      );
    }
    await _startRecording(generation);
  }

  void _nativeStatus(String status) {
    if (_disposed || _recording) return;
    if (status == 'listening') {
      final ready = _nativeReady;
      if (ready != null && !ready.isCompleted) ready.complete(true);
      _setListening(true);
    }
    if (status == 'done' || status == 'notListening') _setListening(false);
  }

  void _nativeError(String error) {
    if (_disposed || _recording) return;
    _setListening(false);
    final code = switch (error) {
      'error_permission' ||
      'error_permission_denied' ||
      'error_insufficient_permissions' => 'speech_permission_denied',
      'error_no_match' || 'error_speech_timeout' => 'speech_no_text',
      _ => 'speech_unavailable',
    };
    _nativeFailure = code;
    final ready = _nativeReady;
    if (ready != null && !ready.isCompleted) ready.complete(false);
    if (!_nativeStarting) _onError?.call(code);
  }

  Future<void> _startRecording(int generation) async {
    final recorder = _recorder ??= AudioRecorder();
    try {
      if (!await recorder.hasPermission()) {
        throw const AssistantFailure('speech_permission_denied');
      }
      if (!_isCurrent(generation)) return;
      // PCM streaming avoids writing sensitive audio to disk. On Linux this
      // requires parecord, not record_linux's ffmpeg file-encoding pipeline.
      final stream = await recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: _sampleRate,
          numChannels: 1,
        ),
      );
      if (!_isCurrent(generation)) {
        await recorder.cancel();
        return;
      }
      _audio = BytesBuilder(copy: false);
      _recording = true;
      _setListening(true);
      _audioSubscription = stream.listen(
        (chunk) {
          final audio = _audio;
          if (!_isCurrent(generation) || !_recording || audio == null) return;
          final remaining = _maxAudioBytes - audio.length;
          if (remaining > 0) {
            audio.add(
              chunk.length <= remaining
                  ? chunk
                  : Uint8List.sublistView(chunk, 0, remaining),
            );
          }
          if (audio.length >= _maxAudioBytes) _finishAtLimit(generation);
        },
        onError: (Object error, StackTrace stack) =>
            _recordingFailed(generation),
        onDone: () {
          if (_recording) _recordingFailed(generation);
        },
      );
      _recordingLimit = Timer(
        const Duration(seconds: 60),
        () => _finishAtLimit(generation),
      );
    } catch (error) {
      await _cancelRecording();
      if (error is AssistantFailure) rethrow;
      throw const AssistantFailure('speech_unavailable');
    }
  }

  void _finishAtLimit(int generation) {
    if (!_isCurrent(generation) || !_recording || _stopping != null) return;
    unawaited(
      stopSpeech().catchError((Object error) {
        if (_isCurrent(generation)) {
          _onError?.call(
            error is AssistantFailure ? error.code : 'speech_unavailable',
          );
        }
      }),
    );
  }

  void _recordingFailed(int generation) {
    if (!_isCurrent(generation) || !_recording) return;
    final cleanup = _cancelRecording();
    _stopping = cleanup;
    unawaited(
      cleanup.whenComplete(() {
        if (identical(_stopping, cleanup)) _stopping = null;
      }),
    );
    _onError?.call('speech_unavailable');
  }

  Future<void> stopSpeech() async {
    if (_disposed) return;
    final pending = _stopping;
    if (pending != null) return pending;
    final operation = _stopSpeech(_generation);
    _stopping = operation;
    try {
      await operation;
    } on AssistantFailure {
      rethrow;
    } catch (_) {
      if (!_disposed) throw const AssistantFailure('speech_unavailable');
    } finally {
      _stopping = null;
    }
  }

  Future<void> _stopSpeech(int generation) async {
    await _starting;
    if (!_isCurrent(generation)) return;
    _recordingLimit?.cancel();
    _recordingLimit = null;
    _setListening(false);
    if (!_recording) {
      if (identical(_speechOwner, this)) await _speech.stop();
      return;
    }
    _recording = false;
    try {
      await _recorder?.stop();
      await _audioSubscription?.cancel();
      _audioSubscription = null;
      final pcm = _audio?.takeBytes();
      _audio = null;
      if (!_isCurrent(generation)) return;
      if (pcm == null || pcm.length < 2) {
        throw const AssistantFailure('speech_no_text');
      }
      if (!_hasTranscription) {
        throw const AssistantFailure('speech_requires_api_key');
      }
      final text = await _transcribe!(
        _wav(pcm),
        filename: 'speech.wav',
        mimeType: 'audio/wav',
      );
      if (!_isCurrent(generation)) return;
      if (text.trim().isEmpty) {
        throw const AssistantFailure('speech_no_text');
      }
      _onText?.call(text.trim());
    } finally {
      await _cancelRecording();
    }
  }

  Future<void> _cancelRecording() async {
    _recording = false;
    _setListening(false);
    _recordingLimit?.cancel();
    _recordingLimit = null;
    _audio = null;
    final subscription = _audioSubscription;
    _audioSubscription = null;
    try {
      await subscription?.cancel();
    } catch (_) {
      // Still release the recorder if a platform stream already closed.
    } finally {
      try {
        await _recorder?.cancel();
      } catch (_) {
        // Cancellation never falls through into transcription.
      }
    }
  }

  Future<AssistantImage?> pasteImage() async {
    if (_disposed) throw const AssistantFailure('media_unavailable');
    try {
      final bytes = await _readClipboardImage();
      if (bytes == null) return null;
      return await _prepareImage(bytes);
    } on AssistantFailure {
      rethrow;
    } on PlatformException catch (error) {
      final denied =
          error.code.toLowerCase().contains('denied') ||
          error.code.toLowerCase().contains('access');
      throw AssistantFailure(
        denied ? 'image_permission_denied' : 'image_unavailable',
      );
    } catch (_) {
      throw const AssistantFailure('image_unavailable');
    }
  }

  Future<AssistantImage?> pickImage({bool camera = false}) async {
    if (_disposed) throw const AssistantFailure('media_unavailable');
    try {
      Uint8List bytes;
      if (Platform.isAndroid || Platform.isIOS) {
        final selected = await ImagePicker().pickImage(
          source: camera ? ImageSource.camera : ImageSource.gallery,
          requestFullMetadata: false,
        );
        if (selected == null) return null;
        try {
          if (_disposed) return null;
          if (await selected.length() > _maxImageBytes) {
            throw const AssistantFailure('image_too_large');
          }
          bytes = await selected.readAsBytes();
        } finally {
          // Mobile image_picker returns an app-cache copy, not a gallery file.
          try {
            await File(selected.path).delete();
          } on FileSystemException {
            // The OS may already have removed its temporary picker copy.
          }
        }
      } else {
        // Desktop image_picker has no camera implementation. Use a real system
        // file dialog even when the caller requested a camera on desktop.
        final selected = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
          allowMultiple: false,
          withData: false,
          withReadStream: true,
        );
        if (selected == null || _disposed) return null;
        final file = selected.files.single;
        if (file.size > _maxImageBytes) {
          throw const AssistantFailure('image_too_large');
        }
        final stream =
            file.readStream ??
            (file.path == null ? null : File(file.path!).openRead());
        if (stream == null) throw const AssistantFailure('image_unavailable');
        final builder = BytesBuilder(copy: false);
        await for (final chunk in stream) {
          if (_disposed) return null;
          if (builder.length + chunk.length > _maxImageBytes) {
            throw const AssistantFailure('image_too_large');
          }
          builder.add(chunk);
        }
        bytes = builder.takeBytes();
      }
      return await _prepareImage(bytes);
    } on AssistantFailure {
      rethrow;
    } on PlatformException catch (error) {
      final denied =
          error.code.toLowerCase().contains('denied') ||
          error.code.toLowerCase().contains('access');
      throw AssistantFailure(
        denied ? 'image_permission_denied' : 'image_unavailable',
      );
    } catch (_) {
      throw const AssistantFailure('image_unavailable');
    }
  }

  Future<AssistantImage?> _prepareImage(Uint8List bytes) async {
    if (_disposed) return null;
    if (bytes.length > _maxImageBytes) {
      throw const AssistantFailure('image_too_large');
    }
    final sanitized = await compute(_sanitizeImage, bytes);
    return _disposed ? null : sanitized;
  }

  /// Clears capture without transcribing when changing account or conversation.
  Future<void> cancelSpeech() async {
    if (_disposed) return;
    ++_generation;
    _onText = null;
    _onError = null;
    _setListening(false);
    try {
      await _starting;
    } catch (_) {
      // Cancellation also covers a rejected permission/start attempt.
    }
    if (identical(_speechOwner, this)) {
      try {
        await _speech.cancel();
      } catch (_) {
        // A missing native recognizer has nothing left to cancel.
      }
    }
    await _cancelRecording();
  }

  /// Cancels, rather than stopping/finishing: leaving the screen never starts
  /// an API transcription and late native/network callbacks are discarded.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    ++_generation;
    _onText = null;
    _onError = null;
    _onListeningChanged = null;
    try {
      await _starting;
    } catch (_) {
      // An interrupted permission/start attempt is no longer a UI failure.
    }
    if (identical(_speechOwner, this)) {
      _speechOwner = null;
      try {
        await _speech.cancel();
      } catch (_) {
        // A missing native recognizer is a supported platform limitation.
      }
    }
    await _cancelRecording();
    await _recorder?.dispose();
    _recorder = null;
  }
}

Uint8List _wav(Uint8List pcm) {
  // A complete mono signed-16-bit little-endian PCM WAV; no names or metadata.
  final length = pcm.length - pcm.length % 2;
  final bytes = Uint8List(44 + length);
  final data = ByteData.sublistView(bytes);
  bytes.setRange(0, 4, const [82, 73, 70, 70]);
  data.setUint32(4, 36 + length, Endian.little);
  bytes.setRange(8, 16, const [87, 65, 86, 69, 102, 109, 116, 32]);
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, 1, Endian.little);
  data.setUint32(24, _sampleRate, Endian.little);
  data.setUint32(28, _sampleRate * 2, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  bytes.setRange(36, 40, const [100, 97, 116, 97]);
  data.setUint32(40, length, Endian.little);
  bytes.setRange(44, bytes.length, pcm);
  return bytes;
}

AssistantImage _sanitizeImage(Uint8List bytes) {
  try {
    final image.Decoder decoder;
    final bool jpeg;
    if (bytes.length >= 3 &&
        bytes[0] == 0xff &&
        bytes[1] == 0xd8 &&
        bytes[2] == 0xff) {
      decoder = image.JpegDecoder();
      jpeg = true;
    } else if (bytes.length >= 8 &&
        bytes[0] == 137 &&
        bytes[1] == 80 &&
        bytes[2] == 78 &&
        bytes[3] == 71 &&
        bytes[4] == 13 &&
        bytes[5] == 10 &&
        bytes[6] == 26 &&
        bytes[7] == 10) {
      decoder = image.PngDecoder();
      jpeg = false;
    } else if (bytes.length >= 12 &&
        bytes[0] == 82 &&
        bytes[1] == 73 &&
        bytes[2] == 70 &&
        bytes[3] == 70 &&
        bytes[8] == 87 &&
        bytes[9] == 69 &&
        bytes[10] == 66 &&
        bytes[11] == 80) {
      decoder = image.WebPDecoder();
      jpeg = false;
    } else {
      throw const AssistantFailure('image_unsupported');
    }
    final info = decoder.startDecode(bytes);
    if (info == null || info.width <= 0 || info.height <= 0) {
      throw const AssistantFailure('image_invalid');
    }
    if (info.width * info.height > _maxImagePixels) {
      throw const AssistantFailure('image_too_large');
    }
    var decoded = decoder.decodeFrame(0);
    if (decoded == null) throw const AssistantFailure('image_invalid');
    final orientation = decoded.exif.imageIfd.orientation;
    if (orientation != null && orientation != 1) {
      decoded = image.bakeOrientation(decoded);
    }
    decoded.exif = image.ExifData();
    decoded.iccProfile = null;
    decoded.textData = null;
    final sanitized = jpeg
        ? image.encodeJpg(decoded, quality: 90)
        : image.encodePng(decoded, singleFrame: true);
    if (sanitized.length > _maxImageBytes) {
      throw const AssistantFailure('image_too_large');
    }
    return AssistantImage(
      bytes: sanitized,
      mimeType: jpeg ? 'image/jpeg' : 'image/png',
    );
  } on AssistantFailure {
    rethrow;
  } catch (_) {
    throw const AssistantFailure('image_invalid');
  }
}
