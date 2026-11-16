import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/features/friends/data/models/relation_nickname_request.dart';
import 'package:frontend/features/friends/data/models/relation_response.dart';
import 'package:frontend/features/friends/domain/repository/relation_repository.dart';
import 'package:frontend/features/posts/domain/entities/post.dart';
import 'package:frontend/features/posts/domain/repositories/posts_repository.dart';
import 'package:frontend/features/posts/presentation/post_list.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../core/storage/auth_storage.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/popup_text.dart';
import '../../../core/widgets/user_avatar.dart';
import '../data/relation_initiator.dart';
import '../data/relation_status.dart';

class ProfileUi extends StatefulWidget {
  final RelationStatus _relationStatus;

  final RelationInitiator? _relationInitiator;

  final VoidCallback _onAccountSettingsPressed;

  final VoidCallback _onEditProfilePressed;

  final RelationRepository _relationRepository;

  final PostsRepository _postsRepository;

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
    required this._postsRepository,
  });

  @override
  State<StatefulWidget> createState() {
    return _ProfileUiState();
  }
}

class _ProfileUiState extends State<ProfileUi> {
  late RelationStatus status;
  late RelationInitiator? initiator;

  List<Post>? _posts;
  bool _isLoadingPosts = false;
  Position? _userPosition;
  String? _postsError;

  @override
  void initState() {
    super.initState();
    status = widget._relationStatus;
    initiator = widget._relationInitiator;
    _loadPostsAndLocation();
  }

  Future<void> _loadPostsAndLocation() async {
    if (status != RelationStatus.accepted && status != RelationStatus.self) {
      return;
    }

    setState(() {
      _isLoadingPosts = true;
      _postsError = null;
    });

    Position? position;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.best,
              timeLimit: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error getting position for profile posts: $e');
    }

    List<Post> fetchedPosts = [];
    try {
      fetchedPosts = await widget._postsRepository.getPostsByNickname(
        widget._nickname,
      );
    } catch (e) {
      debugPrint('Error loading posts for ${widget._nickname}: $e');
      _postsError = 'Failed to load posts';
    }

    if (!mounted) return;
    setState(() {
      _posts = fetchedPosts;
      _userPosition = position;
      _isLoadingPosts = false;
    });
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
    _loadPostsAndLocation();
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
      initiator = RelationInitiator.self;
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
                // TODO: uncomment when reporting implemented
                // IconButton(
                //   onPressed: _reportUser,
                //   iconSize: 40,
                //   icon: const Icon(Icons.report, color: Colors.black),
                // ),
                // TODO: uncomment when blocking implemented
                // IconButton(
                //   onPressed: _blockUser,
                //   iconSize: 40,
                //   icon: const Icon(Icons.block, color: Colors.black),
                // ),
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
                iconSize: 40,
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
            if (widget._bio.isNotEmpty) ...[
              Align(
                alignment: Alignment.center,
                child: Text(
                  widget._bio,
                  style: const TextStyle(fontSize: 20, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
            ] else ...[
              Align(
                alignment: Alignment.center,
                child: Text(
                  'This user has no bio',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 20),
            ...[
              ...switch (status) {
                RelationStatus.pending => [
                  if (initiator == RelationInitiator.self) ...[
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
                  if (initiator == RelationInitiator.self) ...[
                    CustomButton(
                      text: 'Friend request sent',
                      onPressed: () {},
                      backgroundColor: Colors.grey,
                    ),
                  ] else ...[
                    CustomButton(
                      text: 'Send friend request',
                      onPressed: _sendFriendRequest,
                      backgroundColor: Colors.deepPurple,
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

            if (status == RelationStatus.accepted ||
                status == RelationStatus.self) ...[
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: PopupText('Posts'),
              ),
              const SizedBox(height: 12),
              if (_isLoadingPosts) ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ] else if (_postsError != null) ...[
                Center(
                  child: Text(
                    _postsError!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ] else if (_posts == null || _posts!.isEmpty) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    status == RelationStatus.self
                        ? "You haven't created any posts yet"
                        : 'This user has no posts yet',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ] else ...[
                PostList(
                  posts: _posts!,
                  userPosition: _userPosition,
                  onPostTap: (post) {},
                ),
              ],
            ] else ...[
              const SizedBox(height: 60),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Become friends with this user to view the location of their posts!',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ] else ...[
            ...switch (initiator) {
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
