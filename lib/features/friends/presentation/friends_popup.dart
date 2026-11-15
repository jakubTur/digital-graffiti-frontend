import 'package:flutter/material.dart';
import 'package:frontend/core/storage/auth_storage.dart';
import 'package:frontend/features/friends/domain/repository/relation_repository.dart';
import 'package:frontend/features/friends/presentation/friends_list.dart';
import 'package:frontend/features/map/presentation/map_bottom_popup.dart';

class FriendsPopup extends StatelessWidget {
  const FriendsPopup({
    super.key,
    required this.relationRepository,
    required this.authStorage,
  });

  final RelationRepository relationRepository;
  final AuthStorage authStorage;

  @override
  Widget build(BuildContext context) {
    return MapBottomPopup(
      authStorage: authStorage,
      isFriendsOpen: true,
      child: FriendsList(relationRepository: relationRepository),
    );
  }
}
