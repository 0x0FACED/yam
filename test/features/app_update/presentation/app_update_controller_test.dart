import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/features/app_update/data/android_update_installer.dart';
import 'package:yam/features/app_update/data/github_update_client.dart';
import 'package:yam/features/app_update/domain/app_update.dart';
import 'package:yam/features/app_update/presentation/app_update_controller.dart';

void main() {
  late Directory directory;
  late _Client client;
  late _Installer installer;
  late AppUpdateController controller;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('yam-update-state-');
    client = _Client();
    installer = _Installer(directory);
    controller = AppUpdateController(
      installedVersion: '0.1.0+1',
      client: client,
      installer: installer,
    );
  });

  tearDown(() async {
    controller.dispose();
    await directory.delete(recursive: true);
  });

  test(
    'a new release invalidates the previous download for installation',
    () async {
      await controller.check();
      await controller.download();
      expect(controller.status, AppUpdateStatus.ready);
      expect(installer.installations, 0);

      client.release = _release('0.3.0+3');
      await controller.check();
      await controller.install();
      expect(controller.status, AppUpdateStatus.available);
      expect(installer.installations, 0);

      await controller.download();
      await controller.install();
      expect(installer.installedVersion, '0.3.0+3');
    },
  );

  test('permission and canceled handoff preserve the downloaded APK', () async {
    await controller.check();
    await controller.download();
    final apk = File('${directory.path}/${client.release.apkName}');
    installer.result = UpdateInstallResult.permissionRequired;
    await controller.install();
    expect(controller.status, AppUpdateStatus.ready);
    expect(controller.installFailure, AppUpdateInstallFailure.permission);
    expect(await apk.exists(), isTrue);

    installer.result = UpdateInstallResult.started;
    await controller.install();
    expect(controller.status, AppUpdateStatus.ready);
    expect(controller.installFailure, isNull);
    expect(await apk.exists(), isTrue);
  });

  test('a failed recheck does not discard a ready update', () async {
    await controller.check();
    await controller.download();
    client.failure = const AppUpdateException(UpdateFailure.network);
    await controller.check();
    expect(controller.status, AppUpdateStatus.ready);
    expect(controller.failure, UpdateFailure.network);
    await controller.install();
    expect(controller.failure, isNull);
    expect(installer.installedVersion, '0.2.0+2');
  });

  test('parallel download presses cannot overwrite an in-flight APK', () async {
    await controller.check();
    client.downloadGate = Completer<void>();
    final first = controller.download();
    await client.downloadEntered.future;
    await controller.download();
    expect(controller.status, AppUpdateStatus.downloading);
    expect(client.downloads, 1);
    client.downloadGate!.complete();
    await first;
    expect(controller.status, AppUpdateStatus.ready);
  });

  test(
    'signature rejection remains visible without deleting the APK',
    () async {
      await controller.check();
      await controller.download();
      installer.failure = PlatformException(code: 'incompatible_signature');
      await controller.install();
      expect(controller.installFailure, AppUpdateInstallFailure.signature);
      expect(controller.status, AppUpdateStatus.ready);
      expect(
        await File('${directory.path}/${client.release.apkName}').exists(),
        isTrue,
      );
    },
  );
}

AppUpdateRelease _release(String version) => AppUpdateRelease(
  version: AppUpdateVersion.parse(version),
  apkName: 'yam-$version-android.apk',
  apkUrl: Uri.parse(
    'https://github.com/0x0FACED/yam/releases/download/v${version.split('+').first}/yam-$version-android.apk',
  ),
  sizeBytes: 4,
  sha256: '0' * 64,
);

class _Client extends GitHubUpdateClient {
  AppUpdateRelease release = _release('0.2.0+2');
  AppUpdateException? failure;
  Completer<void>? downloadGate;
  final downloadEntered = Completer<void>();
  int downloads = 0;

  @override
  Future<AppUpdateRelease> latest() async {
    if (failure != null) throw failure!;
    return release;
  }

  @override
  Future<File> download(
    AppUpdateRelease release,
    Directory directory, {
    required void Function(int received, int total) onProgress,
  }) async {
    downloads++;
    if (!downloadEntered.isCompleted) downloadEntered.complete();
    if (downloadGate != null) await downloadGate!.future;
    onProgress(2, 4);
    final apk = await File(
      '${directory.path}/${release.apkName}',
    ).writeAsBytes([1, 2, 3, 4]);
    onProgress(4, 4);
    return apk;
  }
}

class _Installer extends AndroidUpdateInstaller {
  _Installer(this.directory);

  final Directory directory;
  UpdateInstallResult result = UpdateInstallResult.started;
  PlatformException? failure;
  int installations = 0;
  String? installedVersion;

  @override
  Future<Directory> updateDirectory() async => directory;

  @override
  Future<UpdateInstallResult> install(
    File apk,
    AppUpdateVersion version,
  ) async {
    if (failure != null) throw failure!;
    installations++;
    installedVersion = version.displayVersion;
    return result;
  }
}
