import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/features/map/data/map_model.dart';
import 'package:frontend/features/map/presentation/map_ui_button.dart';
import 'package:frontend/features/map/presentation/post_view_widget.dart';
import 'package:frontend/features/posts/presentation/post_creation_flow.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/storage/auth_storage.dart';

/// UI containing buttons that display above the map.
class MapUi extends StatefulWidget {
  const MapUi(this._postCreationFlow, {super.key});

  final PostCreationFlow _postCreationFlow;

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
      final drawing = _map.getRootDrawingOnViewedPost();
      if (!mounted || post == null) {
        _isShowingPost = false;
        return;
      }

      unawaited(
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          clipBehavior: Clip.antiAlias,
          builder: (_) => PostViewWidget(post: post, drawing: drawing),
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

  Future<void> _createPost(BuildContext context, MapModel map) async {
    if (await widget._postCreationFlow.run(context, map.userLocation)) {
      await map.refreshPosts();
    }
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
                  onTap: () => _createPost(context, map),
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

  Future<void> _showProfile(BuildContext context, MapModel map) async {
    //kinda sloppy but idk
    final userNickname = await const AuthStorage(FlutterSecureStorage())
        .readNickname();
    if (!context.mounted || userNickname == null) return;
    context.pushNamed('/profile', pathParameters: {'nickname': userNickname});
  }
}
