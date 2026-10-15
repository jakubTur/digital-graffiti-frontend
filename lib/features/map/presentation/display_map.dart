import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/features/map/data/map_model.dart';
import 'package:frontend/features/map/data/post_data.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class TestMap extends StatefulWidget {
  const TestMap({super.key, required this.title});

  final String title;

  @override
  State<TestMap> createState() => _TestMapState();
}

/// State of the test map. Contains information about where the posts are.
class _TestMapState extends State<TestMap> {
  @override
  void initState() {
    super.initState();
    Provider.of<MapModel>(context, listen: false).updateUserLocation();
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
  List<Marker> buildMarkers(LatLng userLocation, MapView<int, PostData> postData) {
    List<Marker> markers = [];
    markers.add(createMarkerFromData(userLocation, Icons.man, Colors.blue));

    for (PostData post in postData.values) {
      markers.add(
        createMarkerFromData(post.location, Icons.location_pin, Colors.green),
      );
    }
    return markers;
  }

  /// Builds the map. Called again when the map changes.
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: "digital-graffiti",
        ),
        Consumer<MapModel>(
          builder: (context, map, child) {
            return MarkerLayer(markers: buildMarkers(map.userLocation, map.posts));
          },
        ),
      ],
    );
  }
}