import 'dart:io';

import 'package:flutter/services.dart';
import 'package:yam/features/app_update/domain/app_update.dart';

enum UpdateInstallResult { started, permissionRequired }

class AndroidUpdateInstaller {
  const AndroidUpdateInstaller();

  static const _channel = MethodChannel('dev.yam.yam/updates');

  Future<void> cleanup() => _channel.invokeMethod<void>('cleanupUpdates');

  Future<Directory> updateDirectory() async {
    final path = await _channel.invokeMethod<String>('getUpdateDirectory');
    if (path == null || path.isEmpty) {
      throw PlatformException(code: 'install_failed');
    }
    return Directory(path);
  }

  Future<UpdateInstallResult> install(
    File apk,
    AppUpdateVersion version,
  ) async {
    final result = await _channel.invokeMethod<String>('installUpdate', {
      'path': apk.path,
      'version': version.version,
      'buildNumber': version.buildNumber,
    });
    return switch (result) {
      'started' => UpdateInstallResult.started,
      'permissionRequired' => UpdateInstallResult.permissionRequired,
      _ => throw PlatformException(code: 'install_failed'),
    };
  }
}
