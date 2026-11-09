import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/features/map/data/map_model.dart';
import 'package:frontend/features/map/presentation/post_pin.dart';
import 'package:frontend/features/posts/domain/entities/post.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class DisplayMap extends StatefulWidget {
  const DisplayMap({super.key});

  @override
  State<DisplayMap> createState() => _DisplayMapState();
}

/// State of the test map. Contains information about where the posts are.
class _DisplayMapState extends State<DisplayMap> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    final mapModel = Provider.of<MapModel>(context, listen: false);
    mapModel.vsync = this;
    mapModel.startUserLocationUpdates();
  }

  // Quick and dirty marker maker
  Marker createMarkerFromData(LatLng location, IconData icon, Color color) {
    return Marker(
      point: location,
      width: 80,
      height: 80,
      child: Icon(icon, color: color, size: 24.0, semanticLabel: 'Marker'),
    );
  }

  /// Builds a list of markers from post data.
  List<Marker> buildMarkers(
    LatLng userLocation,
    List<Post> posts,
    ValueChanged<Post> onViewPost,
  ) {
    List<Marker> markers = [];
    markers.add(createMarkerFromData(userLocation, Icons.man, Colors.blue));

    for (Post post in posts) {
      markers.add(
        Marker(
          point: LatLng(post.latitude, post.longitude),
          width: 80,
          height: 80,
          child: PostPin(post: post, onViewPost: onViewPost),
        ),
      );
    }
    return markers;
  }

  /// Builds the map. Called again when the map changes.
  @override
  Widget build(BuildContext context) {
    final mapModel = Provider.of<MapModel>(context, listen: false);

    return FlutterMap(
      mapController: mapModel.mapController,
      options: const MapOptions(),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: "digital-graffiti",
        ),
        Consumer<MapModel>(
          builder: (context, map, child) {
            return MarkerLayer(
              markers: buildMarkers(
                map.userLocation,
                map.posts,
                map.requestPostView,
              ),
              rotate: true,
            );
          },
        ),
      ],
    );
  }
}
