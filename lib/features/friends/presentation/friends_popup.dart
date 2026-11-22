import 'package:flutter/material.dart';
import 'package:frontend/features/auth/data/datasources/auth_storage.dart';
import 'package:frontend/features/auth/domain/repositories/user_repository.dart';
import 'package:frontend/features/friends/domain/repositories/relation_repository.dart';
import 'package:frontend/features/friends/presentation/friends_list.dart';
import 'package:frontend/features/map/presentation/map_bottom_popup.dart';

class FriendsPopup extends StatelessWidget {
  const FriendsPopup({
    super.key,
    required this.relationRepository,
    required this.authStorage,
    required this.userRepository,
  });

  final RelationRepository relationRepository;
  final UserRepository userRepository;
  final AuthStorage authStorage;

  @override
  Widget build(BuildContext context) {
    return MapBottomPopup(
      authStorage: authStorage,
      isFriendsOpen: true,
      child: FriendsList(
        relationRepository: relationRepository,
        authStorage: authStorage,
        userRepository: userRepository,
      ),
    );
  }
}
