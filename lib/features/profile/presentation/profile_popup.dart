import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/storage/auth_storage.dart';
import 'package:frontend/features/auth/domain/repositories/user_repository.dart';
import 'package:frontend/features/friends/domain/repository/relation_repository.dart';
import 'package:frontend/features/profile/data/relation_initiator.dart';
import 'package:frontend/features/profile/data/relation_status.dart';
import 'package:frontend/features/profile/presentation/account_settings.dart';
import 'package:frontend/features/profile/presentation/edit_profile_ui.dart';
import 'package:frontend/features/profile/presentation/profile_ui.dart';
import 'package:go_router/go_router.dart';

import '../../auth/data/models/user_response.dart';
import '../../friends/data/models/relation_response.dart';

class ProfilePopup extends StatefulWidget {
  const ProfilePopup({
    super.key,
    required this._relationRepository,
    required this._userRepository,
    this._nickname,
  });

  final UserRepository _userRepository;

  final RelationRepository _relationRepository;

  final String? _nickname;

  @override
  State<ProfilePopup> createState() => _ProfilePopupState(_nickname);
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

  _ProfilePopupState(this._nickname);

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userNickname = await const AuthStorage(FlutterSecureStorage())
          .readNickname();
      if (_nickname == userNickname) {
        if (userNickname != null) {
          final UserResponse userResponse = await widget._userRepository
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
              ._relationRepository
              .getRelationByNicknames(userNickname, _nickname!);
          final RelationInitiator initiator =
              relationResponse.senderNickname == userNickname
              ? RelationInitiator.self
              : RelationInitiator.otherUser;
          final RelationStatus status = relationResponse.status;
          final UserResponse userResponse = await widget._userRepository
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
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
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
        userRepository: widget._userRepository,
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
        relationRepository: widget._relationRepository,
        relationStatus: _relationStatus,
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
                  child: _selectScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
