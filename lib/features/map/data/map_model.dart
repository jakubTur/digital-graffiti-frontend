import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/features/posts/domain/entities/drawing.dart';
import 'package:frontend/features/posts/domain/entities/post.dart';
import 'package:frontend/features/posts/domain/repositories/posts_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Data class storing state local to map (user location and posts) pulled from backend.
/// Made with help of state management tutorial: https://docs.flutter.dev/data-and-backend/state-mgmt/simple
class MapModel extends ChangeNotifier {
  MapModel({required this._postsRepository});

  /// How far from the user posts are fetched, in meters.
  static const double postSearchRadius = 50;

  /// How often nearby posts are fetched.
  static const Duration postPollInterval = Duration(seconds: 10);

  final PostsRepository _postsRepository;

  final _mapController = MapController();

  TickerProvider? vsync;

  MapController get mapController => _mapController;

  /// User location to be displayed on the map.
  LatLng _userLocation = LatLng(0, 0);
  bool _isFirstLocation = true;

  List<Post> _posts = const [];

  /// which post is currently being viewed.
  /// this is slightly messy coupling with MapUi, but it's not a massive issue,
  /// and keeping it here allows for easier routing during post viewing.
  Post? _postToView;

  /// all drawings made on the currently viewed post.
  List<Drawing>? _drawingsOnPostToView;

  /// Used to keep track of the user's location
  StreamSubscription<Position>? _positionSubscription;

  /// Periodically fetches nearby posts. Started once the user's location is known.
  Timer? _postPollTimer;

  /// Prevents a slow fetch from overlapping with the next one.
  bool _isFetchingPosts = false;

  /// Network calls can finish after the model is disposed.
  bool _isDisposed = false;

  /// Active animation controller for map movement
  AnimationController? _activeAnimationController;

  /// Active animation controller for location movement
  AnimationController? _locationAnimationController;

  /// Getter for user location
  LatLng get userLocation => _userLocation;

  /// Getter for posts
  UnmodifiableListView<Post> get posts => UnmodifiableListView(_posts);

  Post? get postToView => _postToView;

  List<Drawing>? get drawingsOnPostToView => _drawingsOnPostToView;

  /// getter for the first drawing on a post.
  Drawing? getRootDrawingOnViewedPost() {
    if (drawingsOnPostToView == null) {
      return null;
    }

    for (Drawing drawing in drawingsOnPostToView!) {
      if (drawing.parent_id == -1) {
        // drawing with parent ID of -1 is the root.
        return drawing;
      }
    }
    return null;
  }

  /// post viewing handler.
  /// slightly messy coupling (pedantically this should be in the ui), but it works.
  void requestPostView(Post post) async {
    if (post.id == null) {
      log("Can't view post because its ID is null!");
      return;
    }
    _postToView = post;
    _drawingsOnPostToView = await _postsRepository.getDrawingsByPostId(
      post.id!,
    );
    notifyListeners();
  }

  /// post viewing callback.
  /// slightly messy coupling (pedantically this should be in the ui), but it works.
  void clearPostToView() {
    if (_postToView == null) return;
    _postToView = null;
    notifyListeners();
  }

  /// Replaces the stored posts with those currently near the user.
  /// On failure the previous posts stay visible until the next successful fetch.
  Future<void> refreshPosts() async {
    if (_isFetchingPosts || _isFirstLocation) return;

    _isFetchingPosts = true;
    try {
      _posts = await _postsRepository.getPostsByRadius(
        _userLocation.latitude,
        _userLocation.longitude,
        postSearchRadius,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch posts: $e');
    } finally {
      _isFetchingPosts = false;
    }
  }

  void _startPostPolling() {
    unawaited(refreshPosts());
    _postPollTimer = Timer.periodic(
      postPollInterval,
      (_) => unawaited(refreshPosts()),
    );
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
              _startPostPolling();
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
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    stopLocationUpdates();
    _postPollTimer?.cancel();
    _activeAnimationController?.dispose();
    _locationAnimationController?.dispose();
    super.dispose();
  }
}
