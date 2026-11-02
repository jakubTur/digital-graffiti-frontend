import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

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
  LatLng _userLocation = LatLng(0, 0);
  bool _isFirstLocation = true;

  final Map<int, PostData> _posts = {};
  PostDraft? _currentlyMadePost;

  /// which post is currently being viewed.
  /// this is slightly messy coupling with MapUi, but it's not a massive issue,
  /// and keeping it here allows for easier routing during post viewing.
  PostData? _postToView;

  /// Used to keep track of the user's location
  StreamSubscription<Position>? _positionSubscription;

  /// Active animation controller for map movement
  AnimationController? _activeAnimationController;

  /// Active animation controller for location movement
  AnimationController? _locationAnimationController;

  /// Getter for user location
  LatLng get userLocation => _userLocation;

  /// Getter for posts
  UnmodifiableMapView<int, PostData> get posts => UnmodifiableMapView(_posts);

  PostDraft? get currentlyMadePost => _currentlyMadePost;

  PostData? get postToView => _postToView;

  /// post viewing handler.
  /// slightly messy coupling (pedantically this should be in the ui), but it works.
  void requestPostView(PostData post) {
    _postToView = post;
    notifyListeners();
  }

  /// post viewing callback.
  /// slightly messy coupling (pedantically this should be in the ui), but it works.
  void clearPostToView() {
    if (_postToView == null) return;
    _postToView = null;
    notifyListeners();
  }

  PostDraft beginPost(LatLng location) {
    final post = PostDraft(location: location);
    _currentlyMadePost = post;
    notifyListeners();
    return post;
  }

  void completePost(Uint8List image) {
    final draft = _currentlyMadePost;
    if (draft == null) throw StateError('There is no post in progress.');

    var postId = 1;
    while (_posts.containsKey(postId)) {
      postId++;
    }
    _posts[postId] = draft.complete(image);
    _currentlyMadePost = null;
    notifyListeners();
  }

  void cancelPost() {
    if (_currentlyMadePost == null) return;
    _currentlyMadePost = null;
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
            if (_isFirstLocation) {
              _userLocation = coordinates;
              _isFirstLocation = false;
              recenterMap(coordinates, 19.4, 0.0);
              notifyListeners();
            } else {
              _animateUserLocation(coordinates);
              moveMap(coordinates, 19.4, 0.0);
            }

            debugPrint(
              "New location: ${position.latitude} ${position.longitude}",
            );
          });
    } catch (e) {
      debugPrint(e.toString());
      return;
    }
  }

  void _animateUserLocation(LatLng targetLocation) {
    if (vsync == null) {
      _userLocation = targetLocation;
      notifyListeners();
      return;
    }
    _locationAnimationController?.dispose();
    _locationAnimationController = null;

    final startLocation = _userLocation;
    final latTween = Tween<double>(
      begin: startLocation.latitude,
      end: targetLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: startLocation.longitude,
      end: targetLocation.longitude,
    );

    final controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: vsync!,
    );
    _locationAnimationController = controller;

    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );

    controller.addListener(() {
      _userLocation = LatLng(
        latTween.evaluate(animation),
        lngTween.evaluate(animation),
      );
      notifyListeners();
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        controller.dispose();
        if (_locationAnimationController == controller) {
          _locationAnimationController = null;
        }
      }
    });

    controller.forward();
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

  /// Stop listening to location updates
  void stopLocationUpdates() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// Stream is cancelled when MapModel is disposed
  @override
  void dispose() {
    stopLocationUpdates();
    _activeAnimationController?.dispose();
    _locationAnimationController?.dispose();
    super.dispose();
  }
}
