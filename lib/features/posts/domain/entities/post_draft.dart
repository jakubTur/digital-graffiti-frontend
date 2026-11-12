import 'dart:typed_data';

import 'package:latlong2/latlong.dart';

/// data about a post that is ready to be published.
class PostDraft {
  PostDraft({required this.location, required this.image});

  final LatLng location;
  final Uint8List image;
}
