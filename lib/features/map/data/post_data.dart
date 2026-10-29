import 'dart:typed_data';

import 'package:latlong2/latlong.dart';

/// Class containing data required to display a post.
/// Does NOT contain the post's ID because you should use that as a key in dictionaries storing posts.
class PostData {
  PostData({required this.location, required this.image});

  final LatLng location;
  final Uint8List image;
}

/// data structure containing data about in-progress posts.
/// barebones for now but eh, whatever. will be refactored anyway.
/// TODO: refactor when refactoring post creation
class PostDraft {
  PostDraft({required this.location});

  final LatLng location;

  PostData complete(Uint8List image) => PostData(location: location, image: image);
}
