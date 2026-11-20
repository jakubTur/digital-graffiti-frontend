import 'package:flutter/widgets.dart';

/// Phosphor icons (regular weight) used in the app.
///
/// The phosphor_flutter package's own Dart classes don't compile on current
/// Flutter (they extend IconData, which is now a final class), so we only
/// use the package for its bundled font and define the icons here.
/// Do NOT import 'package:phosphor_flutter/...' anywhere.
///
/// To add an icon, look up its code point in the package's
/// lib/src/phosphor_icons_regular.dart in the pub cache.
abstract final class PhosphorIconsRegular {
  static const _family = 'PhosphorRegular';
  static const _package = 'phosphor_flutter';

  static const arrowCounterClockwise =
      IconData(0xe038, fontFamily: _family, fontPackage: _package);
  static const arrowLeft = IconData(
    0xe058,
    fontFamily: _family,
    fontPackage: _package,
    matchTextDirection: true,
  );
  static const check =
      IconData(0xe182, fontFamily: _family, fontPackage: _package);
  static const eraser =
      IconData(0xe21e, fontFamily: _family, fontPackage: _package);
  static const gradient =
      IconData(0xeb42, fontFamily: _family, fontPackage: _package);
  static const highlighter =
      IconData(0xec76, fontFamily: _family, fontPackage: _package);
  static const paintBrush =
      IconData(0xe6f0, fontFamily: _family, fontPackage: _package);
  static const pen =
      IconData(0xe3aa, fontFamily: _family, fontPackage: _package);
  static const penNib =
      IconData(0xe3ac, fontFamily: _family, fontPackage: _package);
  static const plus =
      IconData(0xe3d4, fontFamily: _family, fontPackage: _package);
  static const sprayBottle =
      IconData(0xe7e4, fontFamily: _family, fontPackage: _package);
  static const trash =
      IconData(0xe4a6, fontFamily: _family, fontPackage: _package);
}
