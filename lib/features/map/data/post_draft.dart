import 'package:latlong2/latlong.dart';

/// data structure containing data about in-progress posts.
/// barebones for now but eh, whatever. will be refactored anyway.
class PostDraft {
  PostDraft({required this.location});

  final LatLng location;
}
