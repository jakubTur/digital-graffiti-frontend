import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'post_data.dart';

/// Data class storing state local to map (user location and posts).
/// Made with help of state management tutorial: https://docs.flutter.dev/data-and-backend/state-mgmt/simple
/// Stores data locally for now. Will be dependant on backend later.
class MapModel extends ChangeNotifier {
  final _mapController = MapController();

  TickerProvider? vsync;

  MapController get mapController => _mapController;

  /// User location to be displayed on the map.
  /// TODO: update periodically (right now updates just once)
  LatLng _userLocation = LatLng(0, 0);

  /// Posts downloaded from the backend will be stored here.
  /// Any posts added here will be displayed on the map
  /// Right now it's just 2 sample posts
  final Map<int, PostData> _posts = {
    1: PostData(location: LatLng(50, 50), title: "Helo"),
    2: PostData(location: LatLng(51, 50), title: "Hiii"),
  };

  /// Used to keep track of the user's location
  StreamSubscription<Position>? _positionSubscription;

  /// Active animation controller for map movement
  AnimationController? _activeAnimationController;

  /// Getter for user location
  LatLng get userLocation => _userLocation;

  /// Getter for posts
  UnmodifiableMapView<int, PostData> get posts => UnmodifiableMapView(_posts);

  /// Tempoerary post-creation method
  /// Call to upload a new post (keeping it locally on the frontend)
  /// TODO: make this send a post creation request to the backend instead
  void upload(PostData newPost) {
    var postId = 1;
    while (_posts.containsKey(postId)) {
      postId++;
    }
    _posts[postId] = newPost;
    notifyListeners();
  }

  /// Call to start updating the user's location
  void startUserLocationUpdates() async {
    // Avoid creating duplicate listeners
    if (_positionSubscription != null) {
      return;
    }

    try {
      await _ensureLocationPermissions();
      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.best,
              distanceFilter: 1,
            ),
          ).listen((Position position) {
            LatLng coordinates = LatLng(position.latitude, position.longitude);
            _userLocation = coordinates;
            moveMap(coordinates, 19.4, 0.0);

            debugPrint(
              "New location: ${position.latitude} ${position.longitude}",
            );
            notifyListeners();
          });
    } catch (e) {
      debugPrint(e.toString());
      return;
    }
  }

  /// Function to move the map to coordinates, change zoom and rotation
  void recenterMap(LatLng center, [double zoom = 19.4, double degree = 0.0]) {
    _mapController.moveAndRotate(center, zoom, degree);
    notifyListeners();
  }

  /// Function to move the map to coordinates smoothly
  void moveMap(LatLng center, double zoom, double rotation) {
    if (vsync == null) {
      _mapController.move(center, zoom);
      return;
    }
    _activeAnimationController?.dispose();
    _activeAnimationController = null;

    final camera = _mapController.camera;
    final latTween = Tween<double>(
      begin: camera.center.latitude,
      end: center.latitude,
    );
    final lngTween = Tween<double>(
      begin: camera.center.longitude,
      end: center.longitude,
    );
    final zoomTween = Tween<double>(begin: camera.zoom, end: zoom);

    final rotationTween = Tween<double>(begin: camera.rotation, end: rotation);

    final controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: vsync!,
    );
    _activeAnimationController = controller;

    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );

    controller.addListener(() {
      _mapController.moveAndRotate(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
        rotationTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        controller.dispose();
        if (_activeAnimationController == controller) {
          _activeAnimationController = null;
        }
      }
    });

    controller.forward();
  }

  /// Checks the location permissions, throws an exception if unavailable
  /// CODE PASTED FROM GEOLOCATOR TUTORIAL: https://pub.dev/packages/geolocator
  Future<void> _ensureLocationPermissions() async {
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
  }

  /// Stream is cancelled when MapModel is disposed
  @override
  void dispose() {
    stopLocationUpdates();
    _activeAnimationController?.dispose();
    super.dispose();
  }

  /// Stop listening to location updates
  void stopLocationUpdates() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }
}
