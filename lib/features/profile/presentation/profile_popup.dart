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
