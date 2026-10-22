import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:yam/app/app.dart';
import 'package:yam/features/startup/presentation/startup_artwork.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final packageInfo = await PackageInfo.fromPlatform();
  final appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';

  StartupArtwork? startupArtwork;
  try {
    startupArtwork = await StartupArtwork.load();
  } on Object catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        context: ErrorDescription('while loading startup artwork'),
      ),
    );
  }

  runApp(YamApp(appVersion: appVersion, startupArtwork: startupArtwork));
}
