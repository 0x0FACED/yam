import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yam/app/router.dart';
import 'package:yam/app/theme/app_scroll_behavior.dart';
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
  late final GoRouter _router;
  bool _startupComplete = false;

  @override
  void initState() {
    super.initState();
    _router = createAppRouter();
  }

  @override
  void dispose() {
    _router.dispose();
    widget.startupArtwork?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      scrollBehavior: const AppScrollBehavior(),
      routerConfig: _router,
      builder: (context, child) {
        if (!_startupComplete) {
          return StartupScreen(
            key: const ValueKey('startup-screen'),
            semanticsLabel: AppLocalizations.of(context).startupLoadingLabel,
            artwork: widget.startupArtwork,
            onFinished: _finishStartup,
          );
        }
        return KeyedSubtree(
          key: const ValueKey('app-content'),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }

  void _finishStartup() {
    if (mounted) {
      setState(() => _startupComplete = true);
    }
  }
}
