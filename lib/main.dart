import 'package:flutter/widgets.dart';
import 'package:yam/app/app.dart';
import 'package:yam/features/startup/presentation/startup_artwork.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(YamApp(startupArtwork: startupArtwork));
}
