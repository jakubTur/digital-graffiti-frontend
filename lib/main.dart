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
    var position = await _determinePosition();
    userLocation = LatLng(position.latitude, position.longitude);
  }

  late LatLng userLocation = LatLng(0, 0);

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: userLocation,
              width: 80,
              height: 80,
              child: Icon(
                Icons.arrow_downward,
                color: Colors.red,
                size: 24.0,
                semanticLabel: 'You are here',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/*
class InheritedMapDisplay extends InheritedWidget {
  LatLng coords = LatLng(0, 0);

  InheritedMapDisplay({this.coords = const LatLng(0, 0), required Widget child})
    : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static InheritedMapDisplay? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InheritedMapDisplay>();
}
*/

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
