import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/features/map/presentation/state/map_model.dart';
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
  late final AnimationController _expandController;
  late final AnimationController _fadeController;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _fadeAnimation;
  bool _wasFetching = false;

  @override
  void initState() {
    super.initState();
    final mapModel = Provider.of<MapModel>(context, listen: false);
    mapModel.vsync = this;
    mapModel.startUserLocationUpdates();

    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    _fadeController.dispose();
    super.dispose();
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

    markers.add(createMarkerFromData(userLocation, Icons.man, Colors.blue));
    return markers;
  }

  /// Calculates the minZoom level so zooming out does not exceed the database post fetch radius.
  double _calculateMinZoom(LatLng focusLocation, Size size) {
    if (size.width <= 0 || size.height <= 0) return 18.0;

    final latRad = focusLocation.latitude * (math.pi / 180.0);
    final latCos = math.cos(latRad);
    final validLatCos = latCos > 0.01 ? latCos : 1.0;
    const earthCircumference = 40075016.686;
    final metersPerPixelAtZoom0 = (earthCircumference * validLatCos) / 256.0;
    final screenRadiusPx = math.min(size.width, size.height) / 2.0;
    final scale =
        (screenRadiusPx * metersPerPixelAtZoom0) / MapModel.postSearchRadius;
    return math.log(scale) / math.ln2;
  }

  /// Builds the map. Called again when the map changes.
  @override
  Widget build(BuildContext context) {
    final mapModel = Provider.of<MapModel>(context, listen: false);
    final size = MediaQuery.sizeOf(context);

    return Consumer<MapModel>(
      builder: (context, map, child) {
        final focusLocation = map.currentFocusLocation;
        final minZoom = _calculateMinZoom(focusLocation, size);

        if (map.isFetchingPosts != _wasFetching) {
          _wasFetching = map.isFetchingPosts;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_wasFetching) {
              _expandController.forward(from: 0.0);
              _fadeController.forward(from: 0.0);
            } else {
              _expandController.forward();
              _fadeController.reverse();
            }
          });
        }

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onScaleUpdate: (details) {
            if (details.pointerCount == 1) {
              final delta = details.focalPointDelta.dx;
              if (delta != 0) {
                final mapController = mapModel.mapController;
                mapController.rotate(
                  mapController.camera.rotation - delta * 0.5,
                );
              }
            }
          },
          child: FlutterMap(
            mapController: mapModel.mapController,
            options: MapOptions(
              minZoom: minZoom,
              interactionOptions: const InteractionOptions(
                flags:
                    InteractiveFlag.all &
                    ~InteractiveFlag.drag &
                    ~InteractiveFlag.pinchMove,
              ),
              onPositionChanged: (camera, hasGesture) {
                final currentTarget = map.currentFocusLocation;
                if (camera.center.latitude != currentTarget.latitude ||
                    camera.center.longitude != currentTarget.longitude) {
                  mapModel.mapController.moveAndRotate(
                    currentTarget,
                    camera.zoom,
                    camera.rotation,
                  );
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: "digital-graffiti",
              ),
              AnimatedBuilder(
                animation: Listenable.merge([_expandAnimation, _fadeAnimation]),
                builder: (context, _) {
                  final fadeValue = _fadeAnimation.value;
                  final expandValue = _expandAnimation.value;

                  if (fadeValue <= 0.0 && !map.isFetchingPosts) {
                    return const SizedBox.shrink();
                  }

                  return CircleLayer(
                    circles: [
                      CircleMarker(
                        point: map.userLocation,
                        radius: MapModel.postSearchRadius * expandValue,
                        useRadiusInMeter: true,
                        color: Colors.blue.withValues(alpha: 0.15 * fadeValue),
                        borderColor: Colors.blue.withValues(
                          alpha: 0.5 * fadeValue,
                        ),
                        borderStrokeWidth: 2 * fadeValue,
                      ),
                    ],
                  );
                },
              ),
              MarkerLayer(
                markers: buildMarkers(
                  map.userLocation,
                  map.posts,
                  map.requestPostView,
                ),
                rotate: true,
              ),
            ],
          ),
        );
      },
    );
  }
}
