import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Map',
      home: const TestMap(title: 'Flutter Map Test'),
    );
  }
}

class TestMap extends StatefulWidget {
  const TestMap({super.key, required this.title});

  final String title;

  @override
  State<TestMap> createState() => _TestMapState();
}

class _TestMapState extends State<TestMap> {
  @override
  void initState() {
    super.initState();
    updateLocation();
  }

  void updateLocation() async {
    Position position = await _determinePosition();
    userLocation = LatLng(position.latitude, position.longitude);
  }

  LatLng userLocation = LatLng(0, 0);

  /// Dummy post locations
  /// TODO: read this from backend and put it here, and that will update the pins
  List<LatLng> post_locations = [
    LatLng(10, 10),
    LatLng(20, 10),
    LatLng(10, 20),
    LatLng(20, 20),
  ];

  // Style information for the user marker
  MarkerData user_marker_data = MarkerData(icon: Icons.man);

  // Style information
  // TODO: replace with a more complex data structure later
  MarkerData post_marker_data = MarkerData(
    icon: Icons.location_pin,
    color: Colors.green,
  );

  // Quick and dirty marker maker
  Marker createMarkerFromData(LatLng location, MarkerData data) {
    return Marker(
      point: location,
      width: 80,
      height: 80,
      child: Icon(
        data.icon,
        color: data.color,
        size: 24.0,
        semanticLabel: 'Marker',
      ),
    );
  }

  // Returns the list of markers required for build.
  List<Marker> buildMarkers() {
    List<Marker> markers = [];
    markers.add(createMarkerFromData(userLocation, user_marker_data));
    for (var post_location in post_locations) {
      markers.add(createMarkerFromData(post_location, post_marker_data));
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        MarkerLayer(markers: buildMarkers()),
      ],
    );
  }
}

/// Data required to display a marker.
class MarkerData {
  MarkerData({this.icon = Icons.location_pin, this.color = Colors.blue});
  final IconData icon;
  final Color color;
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
