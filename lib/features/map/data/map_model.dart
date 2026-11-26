import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/core/storage/auth_storage.dart';
import 'package:frontend/features/posts/domain/entities/drawing.dart';
import 'package:frontend/features/posts/domain/entities/post.dart';
import 'package:frontend/features/posts/domain/repositories/posts_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:frontend/features/friends/domain/repository/relation_repository.dart';
import 'package:frontend/features/profile/data/relation_status.dart';

/// Data class storing state local to map (user location and posts) pulled from backend.
/// Made with help of state management tutorial: https://docs.flutter.dev/data-and-backend/state-mgmt/simple
/// 
/// 
/// 
enum PostAgeFilter {
  all,
  today,
  lastWeek,
  lastMonth,
}

enum PostAuthorFilter {
  all,
  friends,
  strangers,
}


enum PostReadFilter { all,
 read,
 unread }

 
class MapModel extends ChangeNotifier {
  MapModel({required this._postsRepository, required this._authStorage});

  /// How far from the user posts are fetched, in meters.
  static const double postSearchRadius = 50;

  /// How often nearby posts are fetched.
  static const Duration postPollInterval = Duration(seconds: 10);

  final PostsRepository _postsRepository;

  /// reference to AuthStorage.
  final AuthStorage _authStorage;

  final _mapController = MapController();

  TickerProvider? vsync;

  MapController get mapController => _mapController;

  /// User location to be displayed on the map.
  LatLng _userLocation = LatLng(0, 0);
  bool _isFirstLocation = true;

  List<Post> _posts = const [];

  PostAgeFilter _ageFilter = PostAgeFilter.all;

  PostAuthorFilter _authorFilter = PostAuthorFilter.all;


  Set<int> _readPostIds = {};
  final Set<int> _markingReadPostIds = {};

  PostReadFilter _readFilter = PostReadFilter.all;

  PostReadFilter get readFilter => _readFilter;

  bool isPostRead(Post post) =>
      post.id != null && _readPostIds.contains(post.id);

  void setReadFilter(PostReadFilter value) {
    _readFilter = value;
    notifyListeners();
  }


  Set<String> _friendNicknames = {};
  String? _loggedInNickname;

  PostAuthorFilter get authorFilter => _authorFilter;
  bool _filtersVisible = false;

  PostAgeFilter get ageFilter => _ageFilter;
  bool get filtersVisible => _filtersVisible;
  /// which post is currently being viewed.
  /// this is slightly messy coupling with MapUi, but it's not a massive issue,
  /// and keeping it here allows for easier routing during post viewing.
  Post? _postToView;

  /// all drawings made on the currently viewed post.
  List<Drawing>? _drawingsOnPostToView;

  /// current username. used to check which drawings should be displayed as green.
  /// TODO (if needed): change this to work on user ID instead.
  String? _currentUsername;

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


  

List<Post> get visiblePosts {
  final now = DateTime.now();

  final DateTime? cutoff = switch (_ageFilter) {
    PostAgeFilter.all => null,
    PostAgeFilter.today =>
      DateTime(now.year, now.month, now.day),
    PostAgeFilter.lastWeek =>
      now.subtract(const Duration(days: 7)),
    PostAgeFilter.lastMonth =>
      now.subtract(const Duration(days: 30)),
  };

  return _posts.where((post) {
    // Filter by age.
    if (cutoff != null &&
        post.postedAt.toLocal().isBefore(cutoff)) {
      return false;
    }

    // Filter by read status.
    final read = isPostRead(post);

    if (_readFilter == PostReadFilter.read && !read) {
      return false;
    }

    if (_readFilter == PostReadFilter.unread && read) {
      return false;
    }

    // Filter by author.
    switch (_authorFilter) {
      case PostAuthorFilter.all:
        return true;

      case PostAuthorFilter.friends:
        return _friendNicknames.contains(post.username);

      case PostAuthorFilter.strangers:
        if (_loggedInNickname == null) return false;

        return post.username != _loggedInNickname &&
            !_friendNicknames.contains(post.username);
    }
  }).toList();
}




  Post? get postToView => _postToView;

  List<Drawing>? get drawingsOnPostToView => _drawingsOnPostToView;

  /// getter for username.
  String? get currentUsername => _currentUsername;

  /// post viewing handler.
  /// slightly messy coupling (pedantically this should be in the ui), but it works.
  void requestPostView(Post post) async {
    if (post.id == null) {
      log("Can't view post because its ID is null!");
      return;
    }
    List<Drawing> drawings;
    try {
      drawings = await _postsRepository.getDrawingsByPostId(post.id!);
    } catch (e) {
      // still show the post, just without drawings.
      debugPrint('Failed to fetch drawings for post ${post.id}: $e');
      drawings = const [];
    }
    final username = await _authStorage.readNickname();
    // set both together, only after the fetch, so the post view
    // can never open with drawings belonging to a different post.
    _drawingsOnPostToView = drawings;
    _currentUsername = username;
    _postToView = post;
    notifyListeners();
    unawaited(_markPostAsRead(post.id!));
  }

  /// post viewing callback.
  /// slightly messy coupling (pedantically this should be in the ui), but it works.
  void clearPostToView() {
    if (_postToView == null) return;
    _postToView = null;
    _drawingsOnPostToView = null;
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
  unawaited(loadReadPostIds());
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


void toggleFilters() {
  _filtersVisible = !_filtersVisible;
  notifyListeners();
}

void setAgeFilter(PostAgeFilter value) {
  _ageFilter = value;
  notifyListeners();
}

void setAuthorFilter(PostAuthorFilter value) {
  _authorFilter = value;
  notifyListeners();
}

void setFriendNicknames({
  required Set<String> friendNicknames,
  required String currentNickname,
}) {
  _friendNicknames = friendNicknames;
  _loggedInNickname = currentNickname;
  notifyListeners();
}


Future<void> loadFriends(
  RelationRepository relationRepository,
) async {
  final userId = await _authStorage.readId();
  final nickname = await _authStorage.readNickname();

  if (userId == null || nickname == null) {
    return;
  }

  try {
    final relations = await relationRepository.getRelations(
      userId,
      RelationStatus.accepted,
    );

    final friendNicknames = relations.map((relation) {
      if (relation.senderNickname == nickname) {
        return relation.receiverNickname;
      }

      return relation.senderNickname;
    }).where((name) => name.isNotEmpty).toSet();

    if (_isDisposed) return;

    setFriendNicknames(
      friendNicknames: friendNicknames,
      currentNickname: nickname,
    );
  } catch (e) {
    debugPrint('Failed to load friends: $e');
  }
}


Future<void> loadReadPostIds() async {
  try {
    final ids = await _postsRepository.getReadPostIds();

    if (_isDisposed) return;

    _readPostIds.addAll(ids);
    notifyListeners();
  } catch (e) {
    debugPrint('Failed to load read posts: $e');
  }
}

Future<void> _markPostAsRead(int postId) async {
  if (_readPostIds.contains(postId) ||
      _markingReadPostIds.contains(postId)) {
    return;
  }

  _markingReadPostIds.add(postId);

  try {
    await _postsRepository.markPostAsRead(postId);

    if (_isDisposed) return;

    _readPostIds.add(postId);
    notifyListeners();
  } catch (e) {
    debugPrint('Failed to mark post $postId as read: $e');
  } finally {
    _markingReadPostIds.remove(postId);
  }
}



}
