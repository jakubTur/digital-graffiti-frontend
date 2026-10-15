import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/features/map/data/map_model.dart';
import 'package:frontend/features/map/data/post_data.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart'; // TODO: for clustering
import 'package:provider/provider.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart'; // TODO: for vector map

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
    updateLocation();
  }

  void updateLocation() async {
    Position position = await _determinePosition();
    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
    });
  }

  LatLng userLocation = LatLng(0, 0);

  /// Locations of posts. Dummy variables for now.
  /// TODO: replace this with data drawn from backend, and that will update the pins
  /// TODO: replace "post_locations" with more complex data structure, storing post title, content, etc.A
  List<LatLng> post_locations = [
    LatLng(10, 10),
    LatLng(20, 10),
    LatLng(10, 20),
    LatLng(20, 20),
  ];

  // Quick and dirty marker maker
  Marker createMarkerFromData(LatLng location, IconData icon, Color color) {
    return Marker(
      point: location,
      width: 80,
      height: 80,
      child: Icon(icon, color: color, size: 24.0, semanticLabel: 'Marker'),
    );
  }

  // Returns the list of markers required for the build() method.
  // TODO: replace this with a stateful approach (more scalable)
  List<Marker> buildMarkers(MapView<int, PostData> postData) {
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
            return MarkerLayer(markers: buildMarkers(map.posts));
          },
        ), // TODO MAKE THIS A CONSUMER
      ],
    );
  }
}

/// Determine the current position of the device.
/// CODE PASTED FROM GEOLOCATOR TUTORIAL: https://pub.dev/packages/geolocator
Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.',
    );
  }

  return await Geolocator.getCurrentPosition();
}
