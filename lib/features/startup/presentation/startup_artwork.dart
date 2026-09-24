import 'dart:ui' show Brightness, Color;

import 'package:flutter_svg/flutter_svg.dart';
import 'package:yam/app/theme/app_colors.dart';

class StartupArtwork {
  StartupArtwork._(this._lightPictures, this._darkPictures);

  static const ColorMapper darkColorMapper = _DarkIntroInkMapper();

  static const mascot = 'assets/inapp/intro_batat_base.svg';
  static const mouthClosed = 'assets/inapp/intro_mouth_closed.svg';
  static const mouthOpen = 'assets/inapp/intro_mouth_open.svg';
  static const letterY = 'assets/inapp/intro_letter_y.svg';
  static const letterA = 'assets/inapp/intro_letter_a.svg';
  static const letterM = 'assets/inapp/intro_letter_m.svg';
  static const fullLogo = 'assets/inapp/yam_logo_full.svg';

  static const _assets = [
    mascot,
    mouthClosed,
    mouthOpen,
    letterY,
    letterA,
    letterM,
    fullLogo,
  ];

  final Map<String, PictureInfo> _lightPictures;
  final Map<String, PictureInfo> _darkPictures;
  bool _disposed = false;

  static Future<StartupArtwork> load() async {
    final pictures = await Future.wait([
      for (final asset in _assets) vg.loadPicture(SvgAssetLoader(asset), null),
      for (final asset in _assets)
        vg.loadPicture(
          SvgAssetLoader(asset, colorMapper: darkColorMapper),
          null,
        ),
    ]);
    return StartupArtwork._(
      Map.fromIterables(_assets, pictures.take(_assets.length)),
      Map.fromIterables(_assets, pictures.skip(_assets.length)),
    );
  }

  PictureInfo? pictureFor(
    String asset, {
    Brightness brightness = Brightness.light,
  }) => brightness == Brightness.dark
      ? _darkPictures[asset]
      : _lightPictures[asset];

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    for (final picture in [..._lightPictures.values, ..._darkPictures.values]) {
      picture.picture.dispose();
    }
  }
}

class _DarkIntroInkMapper extends ColorMapper {
  const _DarkIntroInkMapper();

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    return switch (color.toARGB32()) {
      0xFF17141C || 0xFF17151C => AppColors.darkTextPrimary,
      _ => color,
    };
  }
}
