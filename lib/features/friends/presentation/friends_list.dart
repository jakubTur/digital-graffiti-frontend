import 'package:flutter/material.dart';
import 'package:frontend/core/storage/auth_storage.dart';
import 'package:frontend/core/widgets/form_secondary_text.dart';
import 'package:frontend/core/widgets/loading_screen.dart';
import 'package:frontend/core/widgets/popup_text.dart';
import 'package:frontend/features/auth/domain/repositories/user_repository.dart';
import 'package:frontend/features/friends/data/models/relation_response.dart';
import 'package:frontend/features/friends/domain/repository/relation_repository.dart';
import 'package:frontend/features/friends/presentation/friend_card.dart';
import 'package:frontend/features/profile/data/relation_status.dart';
import 'package:go_router/go_router.dart';

import '../../auth/data/models/user_response.dart';

class FriendsList extends StatefulWidget {
  const FriendsList({
    super.key,
    required this.relationRepository,
    required this.authStorage,
    required this.userRepository,
  });
  final RelationRepository relationRepository;
  final UserRepository userRepository;
  final AuthStorage authStorage;

  @override
  State<StatefulWidget> createState() {
    return _FriendsListState();
  }
}

class _FriendsListState extends State<FriendsList> {
  bool _isLoading = true;

  List<UserResponse> friends = [];

  List<UserResponse> invites = [];

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  void _loadFriends() async {
    int? userId = await widget.authStorage.readId();
    String? userNickname = await widget.authStorage.readNickname();
    if (userId != null && userNickname != null) {
      /// get friends

      List<RelationResponse> friendRelations = await widget.relationRepository
          .getRelations(userId, RelationStatus.accepted);

      List<UserResponse> loadedFriends = await Future.wait(
        friendRelations.map(
          (relation) => widget.userRepository.getUserByNickname(
            relation.senderNickname == userNickname
                ? relation.receiverNickname
                : relation.senderNickname,
          ),
        ),
      );

      /// get pending invites from others

      List<RelationResponse> pending = await widget.relationRepository
          .getRelations(userId, RelationStatus.pending);

      List<RelationResponse> receivedInvites = pending
          .where((request) => request.senderNickname != userNickname)
          .toList();

      List<UserResponse> loadedInvites = await Future.wait(
        receivedInvites.map(
          (relation) =>
              widget.userRepository.getUserByNickname(relation.senderNickname),
        ),
      );

      if (mounted) {
        setState(() {
          friends = loadedFriends;
          invites = loadedInvites;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const LoadingScreen()
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/map');
                        }
                      },
                      iconSize: 40,
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ],
                ),
                if (invites.isNotEmpty) ...[
                  Column(
                    children: [
                      Row(
                        children: [const PopupText('Invites'), const Spacer()],
                      ),
                      ...invites.map(
                        (invite) => FriendCard(
                          response: invite,
                          onRefresh: _loadFriends,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ],
                const PopupText('Friends'),
                if (friends.isNotEmpty)
                  ...friends.map(
                    (friend) =>
                        FriendCard(response: friend, onRefresh: _loadFriends),
                  )
                else ...[
                  const SizedBox(height: 10),
                  Center(
                    child: FormSecondaryText(
                      'You have no friends :(\nGo out and make some!',
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          );
  }
}
