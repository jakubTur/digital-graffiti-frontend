import 'package:flutter/material.dart';
import 'package:frontend/features/map/presentation/state/map_model.dart';
import 'package:frontend/features/map/presentation/map_ui_button.dart';
import 'package:frontend/features/posts/presentation/post_creation_flow.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../auth/data/datasources/auth_storage.dart';

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

  Future<void> _showProfile(BuildContext context, MapModel map) async {
    final userNickname = await _authStorage.readNickname();
    if (!context.mounted || userNickname == null) return;
    context.pushNamed('/profile', pathParameters: {'nickname': userNickname});
  }

  Future<void> _showFriendsList(BuildContext context, MapModel map) async {
    context.push('/friends');
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer<MapModel>(
                  builder: (context, map, child) {
                    final nickname = map.lastViewedProfileNickname;
                    if (nickname == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                        onPressed: () {
                          map.clearProfileReturn();
                          context.pushNamed(
                            '/profile',
                            pathParameters: {'nickname': nickname},
                          );
                        },
                        icon: const Icon(Icons.arrow_back, size: 20),
                        label: Text(
                          'Profile: $nickname',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Row(
                  children: [
                    Consumer<MapModel>(
                      builder: (context, map, child) {
                        return MapUiButton(
                          onTap: () => _showFriendsList(context, map),
                          icon: Icons.people,
                          heroTag: 'friends_button',
                        );
                      },
                    ),
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
                  onTap: () => map.returnToUserLocation(),
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
}
