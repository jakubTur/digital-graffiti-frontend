import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/storage/auth_storage.dart';
import 'package:frontend/features/auth/data/models/user_update_request.dart';
import 'package:frontend/features/auth/domain/repositories/user_repository.dart';
import 'package:frontend/features/profile/data/user_relation_initiator.dart';
import 'package:frontend/features/profile/data/user_relation_status.dart';
import 'package:frontend/features/profile/presentation/account_settings.dart';
import 'package:frontend/features/profile/presentation/edit_profile_ui.dart';
import 'package:frontend/features/profile/presentation/profile_ui.dart';
import 'package:go_router/go_router.dart';

class ProfilePopup extends StatefulWidget {
  const ProfilePopup(
    this._relationStatus, [
    this._relationInitiator,
    this._userRepository,
    Key? key,
  ]) : super(key: key);

  final UserRelationStatus _relationStatus;

  final UserRelationInitiator? _relationInitiator;

  final UserRepository? _userRepository;

  @override
  State<ProfilePopup> createState() => _ProfilePopupState();
}

class _ProfilePopupState extends State<ProfilePopup> {
  bool _showAccountSettings = false;

  bool _showEditProfile = false;

  bool _isLoading = true;

  String _nickname = 'Nickname';
  String _bio = 'example bio example bio example bio example bio';
  String _email = '';
  bool _verified = false;
  bool _active = true;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (widget._userRepository == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final userId = await const AuthStorage(FlutterSecureStorage()).readId();
      if (userId != null) {
        final userResponse = await widget._userRepository!.getUser(userId);
        if (mounted) {
          setState(() {
            _nickname = userResponse.nickname;
            _bio = userResponse.bio;
            _email = userResponse.email;
            _verified = userResponse.verified;
            _active = userResponse.active;
            _isLoading = false;
            _imageUrl = userResponse.imageUrl;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
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
        _nickname,
        _bio,
        initialProfileImageUrl: _imageUrl,
        userRepository: widget._userRepository,
        onSave: (newNickname, newBio, newImage) async {
          if (widget._userRepository != null) {
            try {
              final userId = await const AuthStorage(FlutterSecureStorage())
                  .readId();
              if (userId != null) {
                final req = UserUpdateRequest(
                  nickname: newNickname,
                  email: _email,
                  verified: _verified,
                  active: _active,
                  bio: newBio,
                );
                final updatedUser = await widget._userRepository!.updateUser(
                  userId,
                  req,
                );
                if (newImage != null) {
                  final tempDirectory = await Directory.systemTemp.createTemp(
                    'profile_picture_upload',
                  );
                  try {
                    final imageFile = File('${tempDirectory.path}/picture.png');
                    await imageFile.writeAsBytes(newImage);
                    await widget._userRepository!.uploadProfilePicture(
                      userId,
                      imageFile.path,
                    );
                  } finally {
                    await tempDirectory.delete(recursive: true);
                  }
                }

                _email = updatedUser.email;
                _verified = updatedUser.verified;
                _active = updatedUser.active;
                await _loadUserProfile();
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update profile: $e')),
                );
              }
            }
          }
          if (mounted) {
            setState(() {
              _nickname = newNickname;
              _bio = newBio;
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
        widget._relationStatus,
        widget._relationInitiator,
        () {
          setState(() {
            _showAccountSettings = true;
          });
        },
        () {
          setState(() {
            _showEditProfile = true;
          });
        },
        _nickname,
        _bio,
        _imageUrl,
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
