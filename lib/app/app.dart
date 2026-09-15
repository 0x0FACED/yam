import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_theme.dart';
import 'package:yam/features/startup/presentation/startup_artwork.dart';
import 'package:yam/features/startup/presentation/startup_screen.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class YamApp extends StatefulWidget {
  const YamApp({this.startupArtwork, super.key});

  final StartupArtwork? startupArtwork;

  @override
  State<YamApp> createState() => _YamAppState();
}

class _YamAppState extends State<YamApp> {
  bool _startupComplete = false;

  @override
  void dispose() {
    widget.startupArtwork?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: _startupComplete
          ? const _AppPlaceholder(key: ValueKey('app-content'))
          : Builder(
              builder: (context) => StartupScreen(
                key: const ValueKey('startup-screen'),
                semanticsLabel: AppLocalizations.of(
                  context,
                ).startupLoadingLabel,
                artwork: widget.startupArtwork,
                onFinished: _finishStartup,
              ),
            ),
    );
  }

  void _finishStartup() {
    if (mounted) {
      setState(() => _startupComplete = true);
    }
  }
}

class _AppPlaceholder extends StatelessWidget {
  const _AppPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          AppLocalizations.of(context).appName,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
    );
  }
}
