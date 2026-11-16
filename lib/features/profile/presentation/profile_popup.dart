import 'package:flutter/material.dart';
import 'package:frontend/core/storage/auth_storage.dart';
import 'package:frontend/core/widgets/loading_screen.dart';
import 'package:frontend/features/auth/domain/repositories/user_repository.dart';
import 'package:frontend/features/friends/domain/repository/relation_repository.dart';
import 'package:frontend/features/map/presentation/map_bottom_popup.dart';
import 'package:frontend/features/posts/domain/repositories/posts_repository.dart';
import 'package:frontend/features/profile/data/relation_initiator.dart';
import 'package:frontend/features/profile/data/relation_status.dart';
import 'package:frontend/features/profile/presentation/account_settings.dart';
import 'package:frontend/features/profile/presentation/edit_profile_ui.dart';
import 'package:frontend/features/profile/presentation/profile_ui.dart';

import '../../auth/data/models/user_response.dart';
import '../../friends/data/models/relation_response.dart';

class ProfilePopup extends StatefulWidget {
  const ProfilePopup({
    super.key,
    required this.relationRepository,
    required this.userRepository,
    required this.authStorage,
    this.nickname,
    this.showTopButtons = true,
    required this.postsRepository,
  });

  final UserRepository userRepository;
  final PostsRepository postsRepository;
  final RelationRepository relationRepository;
  final AuthStorage authStorage;
  final String? nickname;
  final bool showTopButtons;

  @override
  State<ProfilePopup> createState() => _ProfilePopupState();
}

class _ProfilePopupState extends State<ProfilePopup> {
  bool _showAccountSettings = false;
  bool _showEditProfile = false;
  bool _isLoading = true;

  String? _nickname;
  String? _bio;
  String? _imageUrl;

  RelationStatus _relationStatus = RelationStatus.none;
  RelationInitiator? _relationInitiator;

  @override
  void initState() {
    super.initState();
    _nickname = widget.nickname;
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userNickname = await widget.authStorage.readNickname();
      if (_nickname == userNickname) {
        if (userNickname != null) {
          final UserResponse userResponse = await widget.userRepository
              .getUserByNickname(userNickname);
          if (mounted) {
            setState(() {
              _nickname = userResponse.nickname;
              _bio = userResponse.bio;
              _isLoading = false;
              _imageUrl = userResponse.imageUrl;
              _relationStatus = RelationStatus.self;
            });
          }
        }
      } else {
        if (userNickname != null && _nickname != null) {
          final RelationResponse relationResponse = await widget
              .relationRepository
              .getRelationByNicknames(userNickname, _nickname!);
          final RelationInitiator initiator =
              relationResponse.senderNickname == userNickname
              ? RelationInitiator.self
              : RelationInitiator.otherUser;
          final RelationStatus status = relationResponse.status;
          final UserResponse userResponse = await widget.userRepository
              .getUserByNickname(_nickname!);
          if (mounted) {
            setState(() {
              _bio = userResponse.bio;
              _isLoading = false;
              _imageUrl = userResponse.imageUrl;
              _relationInitiator = initiator;
              _relationStatus = status;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _selectScreen() {
    if (_isLoading) {
      return LoadingScreen();
    }

    if (_showAccountSettings) {
      return AccountSettings(
        onBackPressed: () => {
          setState(() {
            _showAccountSettings = false;
          }),
        },
      );
    } else if (_showEditProfile) {
      return EditProfileUi(
        initialNickname: _nickname ?? '',
        initialBio: _bio ?? '',
        initialProfileImageUrl: _imageUrl,
        userRepository: widget.userRepository,
        onSave: (newNickname, newBio, newImage) async {
          if (mounted) {
            await _loadUserProfile();
            setState(() {
              _showEditProfile = false;
            });
          }
        },
        onBackPressed: () => {
          setState(() {
            _showEditProfile = false;
          }),
        },
      );
    } else {
      return ProfileUi(
        relationRepository: widget.relationRepository,
        relationStatus: _relationStatus,
        postsRepository: widget.postsRepository,
        relationInitiator: _relationInitiator,
        onAccountSettingsPressed: () {
          setState(() {
            _showAccountSettings = true;
          });
        },
        onEditProfilePressed: () {
          setState(() {
            _showEditProfile = true;
          });
        },
        nickname: _nickname ?? '',
        bio: _bio ?? '',
        imageUrl: _imageUrl,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MapBottomPopup(
      authStorage: widget.authStorage,
      currentNickname: _nickname,
      isFriendsOpen: false,
      showTopButtons: widget.showTopButtons,
      child: _selectScreen(),
    );
  }
}
