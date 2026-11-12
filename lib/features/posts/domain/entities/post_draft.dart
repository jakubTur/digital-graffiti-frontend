import 'dart:typed_data';

import 'package:latlong2/latlong.dart';

/// data about a post in progress of being published.
class PostDraft {
  PostDraft({required this.location, required this.image, this.backgroundPath});

  final LatLng location;
  final Uint8List image;
  final String? backgroundPath;
}
