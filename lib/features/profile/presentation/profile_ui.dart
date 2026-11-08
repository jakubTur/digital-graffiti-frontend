import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend/features/profile/presentation/profile_button.dart';
import 'package:go_router/go_router.dart';

import '../data/user_relation_initiator.dart';
import '../data/user_relation_status.dart';

class ProfileUi extends StatefulWidget {
  final UserRelationStatus _relationStatus;

  final UserRelationInitiator? _relationInitiator;

  final VoidCallback _onAccountSettingsPressed;

  final VoidCallback _onEditProfilePressed;

  final String _nickname;
  final String _bio;
  final Uint8List? _profileImage;

  const ProfileUi(
    this._relationStatus,
    this._relationInitiator,
    this._onAccountSettingsPressed,
    this._onEditProfilePressed,
    this._nickname,
    this._bio,
    this._profileImage,
  );

  @override
  State<StatefulWidget> createState() {
    return _ProfileUiState();
  }
}

class _ProfileUiState extends State<ProfileUi> {
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
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 10,
        children: [
          Row(
            children: [
              if (widget._relationStatus != UserRelationStatus.SELF) ...[
                IconButton(
                  onPressed: _reportUser,
                  iconSize: 60,
                  icon: const Icon(Icons.report, color: Colors.black),
                ),
                IconButton(
                  onPressed: _blockUser,
                  iconSize: 60,
                  icon: const Icon(Icons.block, color: Colors.black),
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
                icon: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ],
          ),
          Align(
            alignment: Alignment.center,
            child: ClipOval(
              child: Container(
                width: 120,
                height: 120,
                color: Colors.deepPurple.shade50,
                child: widget._profileImage != null
                    ? Image.memory(
                        widget._profileImage!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      )
                    : const Icon(
                        Icons.person,
                        size: 120,
                        color: Colors.deepPurple,
                      ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              widget._nickname,
              style: const TextStyle(
                fontSize: 28,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (widget._relationStatus != UserRelationStatus.BLOCKED) ...[
            Align(
              alignment: Alignment.center,
              child: Text(
                widget._bio,
                style: const TextStyle(fontSize: 20, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            ...[
              ...switch (widget._relationStatus) {
                UserRelationStatus.PENDING => [
                  if (widget._relationInitiator == UserRelationInitiator.SELF)
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

                UserRelationStatus.DECLINED || UserRelationStatus.NONE => [
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

                UserRelationStatus.BLOCKED => throw UnimplementedError(),

                UserRelationStatus.SELF => [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ProfileButton(
                          'Edit profile',
                          widget._onEditProfilePressed,
                          Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ProfileButton(
                          'Account settings',
                          widget._onAccountSettingsPressed,
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
            ...switch (widget._relationInitiator) {
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
    );
  }
}
