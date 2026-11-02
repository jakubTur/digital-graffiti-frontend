import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend/features/map/data/map_model.dart';
import 'package:frontend/features/map/data/post_data.dart';
import 'package:frontend/features/map/presentation/post_view_widget.dart';
import 'package:frontend/features/map/presentation/map_ui_button.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// UI containing buttons that display above the map.
class MapUi extends StatefulWidget {
  const MapUi({super.key});

  @override
  State<MapUi> createState() => _MapUiState();
}

/// contains UI-specific state that doesn't need to be in MapModel.
class _MapUiState extends State<MapUi> {

  /// model containing map data.
  /// reference map state here.
  late final MapModel _map;

  /// set to true/false if viewing post.
  bool _isShowingPost = false;

  @override
  void initState() {
    super.initState();
    _map = context.read<MapModel>();
    _map.addListener(_onMapChanged);
  }

  @override
  void dispose() {
    _map.removeListener(_onMapChanged);
    super.dispose();
  }

  void _onMapChanged() {
    if (_isShowingPost || _map.postToView == null) return;
    _isShowingPost = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final post = _map.postToView;
      if (!mounted || post == null) {
        _isShowingPost = false;
        return;
      }

      unawaited(
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          clipBehavior: Clip.antiAlias,
          builder: (_) => PostViewWidget(post: post),
        ).whenComplete(() {
          if (identical(_map.postToView, post)) {
            _map.clearPostToView();
          }
          _isShowingPost = false;
          if (mounted && _map.postToView != null) _onMapChanged();
        }),
      );
    });
  }

  // temporary dirty post creation method.
  // TODO: punt this method into orbit when converting to properly viewing the posts in backend.
  // or at the very least, find a more appropriate place for it.
  Future<void> _createPost(BuildContext context, MapModel map, String path) async {
    final post = map.beginPost(map.userLocation);
    try {
      final image = await context.push<Uint8List>(path, extra: post);
      if (image == null) {
        map.cancelPost();
      } else {
        map.completePost(image);
      }
    } catch (error) {
      map.cancelPost();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create post: $error')),
        );
      }
    }
  }

  /// shows options: create post from drawing, or from photo.
  void _showCanvasOptions(BuildContext context, MapModel map) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Choose Graffiti Type',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'Inter',
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            ElevatedButton.icon(
              icon: const Icon(Icons.brush),
              label: const Text('Drawing'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _createPost(context, map, '/post/draw');
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Photo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _createPost(context, map, '/post/camera');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        alignment: const Alignment(1, 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Consumer<MapModel>(
                  builder: (context, map, child) {
                    return MapUiButton(
                      onTap: () => _showProfile(context, map),
                      icon: Icons.person,
                      heroTag: 'profile_button',
                    );
                  },
                ),
              ],
            ),
            const Spacer(),
            Consumer<MapModel>(
              builder: (context, map, child) {
                return MapUiButton(
                  onTap: () => _showCanvasOptions(context, map),
                  icon: Icons.add_circle,
                  heroTag: 'upload_button',
                );
              },
            ),
            Consumer<MapModel>(
              builder: (context, map, child) {
                return MapUiButton(
                  onTap: () => map.moveMap(map.userLocation, 19.4, 0.0),
                  icon: Icons.my_location,
                  heroTag: 'location_button',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showProfile(BuildContext context, MapModel map) {
    context.push('/profile');
  }
}
