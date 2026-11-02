import 'package:flutter/material.dart';
import 'package:frontend/features/profile/data/user_relation_initiator.dart';
import 'package:frontend/features/profile/data/user_relation_status.dart';
import 'package:frontend/features/profile/presentation/profile_button.dart';
import 'package:go_router/go_router.dart';

class ProfileUi extends StatelessWidget {
  const ProfileUi(this._relationStatus, [this._relationInitiator]);

  final UserRelationStatus _relationStatus;

  final UserRelationInitiator? _relationInitiator;

  //TODO: implement the placeholder functions

  void _blockUser() {}

  void _reportUser() {}

  void _unblockUser() {}

  void _removeFriend() {}

  void _acceptFriendRequest() {}

  void _sendFriendRequest() {}

  void _declineFriendRequest() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/map');
                }
              },
              child: const SizedBox.expand(),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(
                  left: 12.0,
                  right: 12.0,
                  bottom: 12.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(color: Colors.white38, width: 1),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 12),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.0),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 10,
                      children: [
                        Row(
                          children: [
                            if (_relationStatus != UserRelationStatus.SELF) ...[
                              IconButton(
                                onPressed: _reportUser,
                                iconSize: 60,
                                icon: const Icon(
                                  Icons.report,
                                  color: Colors.black,
                                ),
                              ),
                              IconButton(
                                onPressed: _blockUser,
                                iconSize: 60,
                                icon: const Icon(
                                  Icons.block,
                                  color: Colors.black,
                                ),
                              ),
                            ],

                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go('/map');
                                }
                              },
                              iconSize: 60,
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const Align(
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.person,
                            size: 120,
                            color: Colors.deepPurple,
                          ),
                        ),

                        ///TODO: change exemplary values to ones taken from the backend
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Nickname',
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_relationStatus != UserRelationStatus.BLOCKED) ...[
                          const Align(
                            alignment: Alignment.center,
                            child: Text(
                              'bio bio bi bio bo ibo ibo bio bio bio bo bio bio bio bio bio bio',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ...[
                            ...switch (_relationStatus) {
                              UserRelationStatus.PENDING => [
                                if (_relationInitiator ==
                                    UserRelationInitiator.SELF)
                                  ...[]
                                else ...[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ProfileButton(
                                          'Accept friend request',
                                          _acceptFriendRequest,
                                          Colors.green,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ProfileButton(
                                          'Decline friend request',
                                          _declineFriendRequest,
                                          Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],

                              UserRelationStatus.ACCEPTED => [
                                ProfileButton(
                                  'Remove from friends',
                                  _removeFriend,
                                  Colors.red,
                                ),
                              ],

                              UserRelationStatus.DECLINED ||
                              UserRelationStatus.NONE => [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ProfileButton(
                                      'Send friend request',
                                      _sendFriendRequest,
                                      Colors.deepPurple,
                                    ),
                                  ],
                                ),
                              ],

                              UserRelationStatus.BLOCKED =>
                                throw UnimplementedError(),

                              ///TODO: routing
                              UserRelationStatus.SELF => [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: ProfileButton(
                                        'Edit profile',
                                        () {},
                                        Colors.deepPurple,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ProfileButton(
                                        'Account settings',
                                        () {},
                                        Colors.deepPurple,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            },
                          ],

                          const SizedBox(height: 24),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Posts',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          //TODO: List of posts
                        ] else ...[
                          ...switch (_relationInitiator) {
                            null => throw UnimplementedError(),

                            UserRelationInitiator.SELF => [
                              const Text(
                                'This user has been blocked',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: ProfileButton(
                                      'Unblock user',
                                      _unblockUser,
                                      Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            UserRelationInitiator.OTHER_USER => [
                              const Text(
                                'This user has blocked you',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          },
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
