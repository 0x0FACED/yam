import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:yam/features/app_update/data/android_update_installer.dart';
import 'package:yam/features/app_update/data/github_update_client.dart';
import 'package:yam/features/app_update/domain/app_update.dart';

enum AppUpdateStatus {
  idle,
  checking,
  upToDate,
  available,
  downloading,
  ready,
  installing,
}

enum AppUpdateInstallFailure { permission, signature, invalidApk, failed }

/// App-owned so leaving Settings does not interrupt an active download.
class AppUpdateController extends ChangeNotifier {
  AppUpdateController({
    required String installedVersion,
    required GitHubUpdateClient client,
    required AndroidUpdateInstaller installer,
  }) : _installed = AppUpdateVersion.parse(installedVersion),
       _client = client,
       _installer = installer;

  final AppUpdateVersion _installed;
  final GitHubUpdateClient _client;
  final AndroidUpdateInstaller _installer;
  AppUpdateStatus _status = AppUpdateStatus.idle;
  AppUpdateRelease? _release;
  File? _apk;
  UpdateFailure? _failure;
  AppUpdateInstallFailure? _installFailure;
  int _received = 0;
  int _total = 0;
  bool _disposed = false;

  AppUpdateStatus get status => _status;
  AppUpdateRelease? get release => _release;
  UpdateFailure? get failure => _failure;
  AppUpdateInstallFailure? get installFailure => _installFailure;
  int get receivedBytes => _received;
  int get totalBytes => _total;
  double get progress => _total == 0 ? 0 : _received / _total;
  bool get busy => switch (_status) {
    AppUpdateStatus.checking ||
    AppUpdateStatus.downloading ||
    AppUpdateStatus.installing => true,
    _ => false,
  };

  Future<void> check() async {
    if (_disposed || busy) return;
    final previous = _status;
    _failure = null;
    _installFailure = null;
    _status = AppUpdateStatus.checking;
    _emit();
    try {
      final candidate = await _client.latest();
      if (_disposed) return;
      if (!candidate.version.isNewerThan(_installed)) {
        _release = null;
        _status = AppUpdateStatus.upToDate;
      } else {
        final sameDownload =
            _release?.apkName == candidate.apkName &&
            _release?.sha256 == candidate.sha256 &&
            _apk != null &&
            await _apk!.exists();
        if (_disposed) return;
        _release = candidate;
        _status = sameDownload
            ? AppUpdateStatus.ready
            : AppUpdateStatus.available;
      }
    } on AppUpdateException catch (error) {
      if (_disposed) return;
      _failure = error.failure;
      _status = previous;
    } catch (_) {
      if (_disposed) return;
      _failure = UpdateFailure.network;
      _status = previous;
    }
    _emit();
  }

  Future<void> download() async {
    final candidate = _release;
    if (_disposed ||
        _status != AppUpdateStatus.available ||
        candidate == null) {
      return;
    }
    _failure = null;
    _installFailure = null;
    _received = 0;
    _total = candidate.sizeBytes;
    _status = AppUpdateStatus.downloading;
    _emit();
    try {
      final directory = await _installer.updateDirectory();
      if (_disposed) return;
      _apk = await _client.download(
        candidate,
        directory,
        onProgress: (received, total) {
          if (_disposed) return;
          // Only rebuild for a visible percent change, not every network chunk.
          final previousPercent = (_received * 100 ~/ _total.clamp(1, 1 << 62));
          _received = received;
          _total = total;
          if (received == total ||
              received * 100 ~/ total.clamp(1, 1 << 62) != previousPercent) {
            _emit();
          }
        },
      );
      if (_disposed) return;
      _status = AppUpdateStatus.ready;
    } on AppUpdateException catch (error) {
      if (_disposed) return;
      _failure = error.failure;
      _status = AppUpdateStatus.available;
    } catch (_) {
      if (_disposed) return;
      _failure = UpdateFailure.download;
      _status = AppUpdateStatus.available;
    }
    _emit();
  }

  Future<void> install() async {
    final candidate = _release;
    final apk = _apk;
    if (_disposed ||
        _status != AppUpdateStatus.ready ||
        candidate == null ||
        apk == null) {
      return;
    }
    _failure = null;
    _installFailure = null;
    _status = AppUpdateStatus.installing;
    _emit();
    try {
      if (!await apk.exists()) {
        _apk = null;
        _failure = UpdateFailure.download;
        _status = AppUpdateStatus.available;
      } else {
        final result = await _installer.install(apk, candidate.version);
        if (_disposed) return;
        if (result == UpdateInstallResult.permissionRequired) {
          _installFailure = AppUpdateInstallFailure.permission;
        }
        // Launching the installer is not evidence of successful installation.
        _status = AppUpdateStatus.ready;
      }
    } on PlatformException catch (error) {
      if (_disposed) return;
      _installFailure = switch (error.code) {
        'incompatible_signature' => AppUpdateInstallFailure.signature,
        'invalid_apk' => AppUpdateInstallFailure.invalidApk,
        _ => AppUpdateInstallFailure.failed,
      };
      _status = AppUpdateStatus.ready;
    } catch (_) {
      if (_disposed) return;
      _installFailure = AppUpdateInstallFailure.failed;
      _status = AppUpdateStatus.ready;
    }
    _emit();
  }

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _client.close();
    super.dispose();
  }
}
