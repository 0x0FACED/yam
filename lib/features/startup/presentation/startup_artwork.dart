import 'package:flutter_svg/flutter_svg.dart';

class StartupArtwork {
  StartupArtwork._(this._pictures);

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

  final Map<String, PictureInfo> _pictures;
  bool _disposed = false;

  static Future<StartupArtwork> load() async {
    final pictures = await Future.wait(
      _assets.map((asset) => vg.loadPicture(SvgAssetLoader(asset), null)),
    );
    return StartupArtwork._(Map.fromIterables(_assets, pictures));
  }

  PictureInfo? pictureFor(String asset) => _pictures[asset];

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    for (final picture in _pictures.values) {
      picture.picture.dispose();
    }
  }
}
