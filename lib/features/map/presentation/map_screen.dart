import 'package:flutter/material.dart';
import 'package:frontend/features/auth/domain/repositories/user_repository.dart';
import 'package:frontend/features/map/data/map_model.dart';
import 'package:frontend/features/map/presentation/map_ui.dart';
import 'package:frontend/features/posts/domain/repositories/posts_repository.dart';
import 'package:frontend/features/posts/presentation/post_creation_flow.dart';
import 'package:provider/provider.dart';

import 'display_map.dart';

/// Main screen of the app, containing the map and its model (aka state repository)
class MapScreen extends StatelessWidget {
  const MapScreen(this._userRepository, {
    super.key,
    required this.postsRepository,
    required this.postCreationFlow,
  });

  final PostsRepository postsRepository;
  final PostCreationFlow postCreationFlow;

  final UserRepository _userRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (context) => MapModel(postsRepository: postsRepository), // Map-wide state
        child: Stack(children: [DisplayMap(), MapUi(_userRepository, postCreationFlow)]), // Map widget
      ),
    );
  }
}
