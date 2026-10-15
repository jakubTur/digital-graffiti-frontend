import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'post_data.dart';

/// Data class encapsulating map state.
/// Made with help of state management tutorial: https://docs.flutter.dev/data-and-backend/state-mgmt/simple
/// Local for now. Will be dependant on backend later.
class MapModel extends ChangeNotifier {
  final Map<int, PostData> _posts = { // test values
    1: PostData(location: LatLng(50, 50), title: "Helo"),
    2: PostData(location: LatLng(51, 50), title: "Hiii")
  };

  LatLng userLocation = LatLng(0, 0);

  UnmodifiableMapView<int, PostData> get posts => UnmodifiableMapView(_posts);

  /// Tempoerary post-creation method
  /// Call to upload a new post (keeping it locally on the frontend)
  /// TODO: replace with backend implementation
  void upload(PostData newPost) {
    var post_id = 1;
    while (_posts.containsKey(post_id)) {
      post_id++;
    }
    _posts[post_id] = newPost;
    notifyListeners();
  }

  void updateUserLocation()async {
    Position position = await _determinePosition();
    userLocation = LatLng(position.latitude, position.longitude);
    notifyListeners();
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
}
