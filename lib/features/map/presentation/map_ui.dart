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
              mainAxisAlignment: MainAxisAlignment.end,
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
            
Consumer<MapModel>(
  builder: (context, map, child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        MapUiButton(
          onTap: map.toggleFilters,
          icon: map.filtersVisible
              ? Icons.close
              : Icons.filter_list,
          heroTag: 'filters_button',
        ),

        if (map.filtersVisible)
          Card(
            margin: const EdgeInsets.only(right: 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Filter posts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text('Post age'),

                  DropdownButton<PostAgeFilter>(
                    value: map.ageFilter,
                    items: const [
                      DropdownMenuItem(
                        value: PostAgeFilter.all,
                        child: Text('All posts'),
                      ),
                      DropdownMenuItem(
                        value: PostAgeFilter.today,
                        child: Text('Today'),
                      ),
                      DropdownMenuItem(
                        value: PostAgeFilter.lastWeek,
                        child: Text('Last 7 days'),
                      ),
                      DropdownMenuItem(
                        value: PostAgeFilter.lastMonth,
                        child: Text('Last 30 days'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        map.setAgeFilter(value);
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  const Text('Post author'),

                  DropdownButton<PostAuthorFilter>(
                    value: map.authorFilter,
                    items: const [
                      DropdownMenuItem(
                        value: PostAuthorFilter.all,
                        child: Text('Everyone'),
                      ),
                      DropdownMenuItem(
                        value: PostAuthorFilter.friends,
                        child: Text('Friends'),
                      ),
                      DropdownMenuItem(
                        value: PostAuthorFilter.strangers,
                        child: Text('Strangers'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        map.setAuthorFilter(value);
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  const Text('Read status'),

                  DropdownButton<PostReadFilter>(
                    value: map.readFilter,
                    items: const [
                      DropdownMenuItem(
                        value: PostReadFilter.all,
                        child: Text('All posts'),
                      ),
                      DropdownMenuItem(
                        value: PostReadFilter.read,
                        child: Text('Read'),
                      ),
                      DropdownMenuItem(
                        value: PostReadFilter.unread,
                        child: Text('Unread'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        map.setReadFilter(value);
                      }
                    },
                  ),

                ],
              ),
            ),
          ),
      ],
    );
  },
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
}
