import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/features/friends/data/models/relation_nickname_request.dart';
import 'package:frontend/features/friends/data/models/relation_response.dart';
import 'package:frontend/features/friends/domain/repository/relation_repository.dart';
import 'package:go_router/go_router.dart';

import '../../../core/storage/auth_storage.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/user_avatar.dart';
import '../data/relation_initiator.dart';
import '../data/relation_status.dart';

class ProfileUi extends StatefulWidget {
  final RelationStatus _relationStatus;

  final RelationInitiator? _relationInitiator;

  final VoidCallback _onAccountSettingsPressed;

  final VoidCallback _onEditProfilePressed;

  final RelationRepository _relationRepository;

  final String _nickname;
  final String _bio;
  final String? _imageUrl;

  const ProfileUi({
    required this._relationStatus,
    this._relationInitiator,
    required this._onAccountSettingsPressed,
    required this._onEditProfilePressed,
    required this._nickname,
    required this._bio,
    this._imageUrl,
    super.key,
    required this._relationRepository,
  });

  @override
  State<StatefulWidget> createState() {
    return _ProfileUiState();
  }
}

class _ProfileUiState extends State<ProfileUi> {
  late RelationStatus status;

  @override
  void initState() {
    super.initState();
    status = widget._relationStatus;
  }

  Future<String?> _getUserNickname() async {
    return await const AuthStorage(FlutterSecureStorage()).readNickname();
  }

  Future<void> _removeFriend() async {
    final userNickname = await _getUserNickname();
    if (userNickname == null) return;
    await widget._relationRepository.deleteRelation(
      userNickname,
      widget._nickname,
    );
    if (!mounted) return;
    setState(() {
      status = RelationStatus.none;
    });
  }

  Future<void> _acceptFriendRequest() async {
    final userNickname = await _getUserNickname();
    if (userNickname == null) return;
    RelationNicknameRequest request = RelationNicknameRequest(
      senderNickname: widget._nickname,
      receiverNickname: userNickname,
      status: RelationStatus.accepted,
    );
    await widget._relationRepository.updateRelation(request);
    if (!mounted) return;
    setState(() {
      status = RelationStatus.accepted;
    });
  }

  Future<void> _sendFriendRequest() async {
    final userNickname = await _getUserNickname();
    if (userNickname == null) return;
    RelationNicknameRequest request = RelationNicknameRequest(
      senderNickname: userNickname,
      receiverNickname: widget._nickname,
      status: RelationStatus.pending,
    );
    RelationResponse currentRelation = await widget._relationRepository
        .getRelationByNicknames(userNickname, widget._nickname);
    if (currentRelation.status == RelationStatus.none) {
      await widget._relationRepository.createRelationByNicknames(request);
    } else {
      await widget._relationRepository.updateRelation(request);
    }
    if (!mounted) return;
    setState(() {
      status = RelationStatus.pending;
    });
  }

  Future<void> _declineFriendRequest() async {
    final userNickname = await _getUserNickname();
    if (userNickname == null) return;
    RelationNicknameRequest request = RelationNicknameRequest(
      senderNickname: widget._nickname,
      receiverNickname: userNickname,
      status: RelationStatus.declined,
    );
    await widget._relationRepository.updateRelation(request);
    if (!mounted) return;
    setState(() {
      status = RelationStatus.declined;
    });
  }

  //TODO: implement blocking after table refactor

  void _blockUser() {}

  void _reportUser() {}

  void _unblockUser() {}

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
              if (status != RelationStatus.self) ...[
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
            child: UserAvatar(imageUrl: widget._imageUrl),
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
          if (status != RelationStatus.blocked) ...[
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
              ...switch (status) {
                RelationStatus.pending => [
                  if (widget._relationInitiator == RelationInitiator.self) ...[
                    CustomButton(
                      text: 'Friend request sent',
                      onPressed: () {},
                      backgroundColor: Colors.grey,
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Accept friend request',
                            onPressed: _acceptFriendRequest,
                            backgroundColor: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: 'Decline friend request',
                            onPressed: _declineFriendRequest,
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],

                RelationStatus.accepted => [
                  CustomButton(
                    text: 'Remove from friends',
                    onPressed: _removeFriend,
                    backgroundColor: Colors.red,
                  ),
                ],

                RelationStatus.declined => [
                  if (widget._relationInitiator == RelationInitiator.self) ...[
                    CustomButton(
                      text: 'Friend request sent',
                      onPressed: () {},
                      backgroundColor: Colors.grey,
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Accept friend request',
                            onPressed: _acceptFriendRequest,
                            backgroundColor: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: 'Decline friend request',
                            onPressed: _declineFriendRequest,
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],

                RelationStatus.none => [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        text: 'Send friend request',
                        onPressed: _sendFriendRequest,
                        backgroundColor: Colors.deepPurple,
                      ),
                    ],
                  ),
                ],

                RelationStatus.blocked => throw UnimplementedError(),

                RelationStatus.self => [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Edit profile',
                          onPressed: widget._onEditProfilePressed,
                          backgroundColor: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: 'Account settings',
                          onPressed: widget._onAccountSettingsPressed,
                          backgroundColor: Colors.deepPurple,
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

              RelationInitiator.self => [
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
                      child: CustomButton(
                        text: 'Unblock user',
                        onPressed: _unblockUser,
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],

              RelationInitiator.otherUser => [
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
