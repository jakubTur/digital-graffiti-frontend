import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend/features/profile/data/user_relation_initiator.dart';
import 'package:frontend/features/profile/data/user_relation_status.dart';
import 'package:frontend/features/profile/presentation/account_settings.dart';
import 'package:frontend/features/profile/presentation/edit_profile_ui.dart';
import 'package:frontend/features/profile/presentation/profile_ui.dart';
import 'package:go_router/go_router.dart';

class ProfilePopup extends StatefulWidget {
  const ProfilePopup(this._relationStatus, [this._relationInitiator, Key? key])
    : super(key: key);

  final UserRelationStatus _relationStatus;

  final UserRelationInitiator? _relationInitiator;

  @override
  State<ProfilePopup> createState() => _ProfilePopupState();
}

class _ProfilePopupState extends State<ProfilePopup> {
  bool _showAccountSettings = false;

  bool _showEditProfile = false;

  // TODO: get data from the backend
  String _nickname = 'Nickname';
  String _bio = 'example bio example bio example bio example bio';
  Uint8List? _profileImage;

  Widget _selectScreen() {
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
        initialProfileImage: _profileImage,
        onSave: (newNickname, newBio, newImage) {
          // TODO: get rid of this after backend integration ig?
          //  profile should reload from backend after editing I think
          setState(() {
            _nickname = newNickname;
            _bio = newBio;
            _profileImage = newImage;
            _showEditProfile = false;
          });
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
        _profileImage,
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
