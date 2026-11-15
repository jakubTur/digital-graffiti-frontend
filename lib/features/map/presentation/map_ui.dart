import 'package:flutter/material.dart';
import 'package:frontend/features/map/data/map_model.dart';
import 'package:frontend/features/map/presentation/map_ui_button.dart';
import 'package:frontend/features/posts/presentation/post_creation_flow.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/storage/auth_storage.dart';

/// UI containing buttons that display above the map.
/// stateless now that we have a separate class for post creation flow
class MapUi extends StatelessWidget {
  const MapUi(this._authStorage, this._postCreationFlow, {super.key});

  final AuthStorage _authStorage;
  final PostCreationFlow _postCreationFlow;

  Future<void> _createPost(BuildContext context, MapModel map) async {
    if (await _postCreationFlow.run(context, map.userLocation)) {
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
    final userNickname = await _authStorage.readNickname();
    if (!context.mounted || userNickname == null) return;
    context.pushNamed('/profile', pathParameters: {'nickname': userNickname});
  }
}
