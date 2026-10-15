import 'package:latlong2/latlong.dart';

/// Class containing data required to display a post.
/// Does NOT contain the post's ID because you should use that as a key in dictionaries storing posts.
class PostData {
  PostData({required this.location, required this.title});
  LatLng location;
  String title;
}
