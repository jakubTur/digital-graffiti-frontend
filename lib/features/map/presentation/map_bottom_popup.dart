import 'package:flutter/material.dart';
import 'package:frontend/core/storage/auth_storage.dart';
import 'package:frontend/features/map/presentation/map_ui_button.dart';
import 'package:go_router/go_router.dart';

class MapBottomPopup extends StatelessWidget {
  const MapBottomPopup({
    super.key,
    required this.authStorage,
    required this.child,
    this.currentNickname,
    this.isFriendsOpen = false,
    this.showTopButtons = true,
  });

  final AuthStorage authStorage;
  final Widget child;
  final String? currentNickname;
  final bool isFriendsOpen;
  final bool showTopButtons;

  Future<void> _handleFriendsTap(BuildContext context) async {
    if (isFriendsOpen) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/map');
      }
    } else {
      if (context.canPop()) {
        context.pushReplacement('/friends');
      } else {
        context.go('/friends');
      }
    }
  }

  Future<void> _handleProfileTap(BuildContext context) async {
    final userNickname = await authStorage.readNickname();
    if (!context.mounted || userNickname == null) return;

    if (!isFriendsOpen && currentNickname == userNickname) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/map');
      }
    } else {
      if (context.canPop()) {
        context.pushReplacementNamed(
          '/profile',
          pathParameters: {'nickname': userNickname},
        );
      } else {
        context.pushNamed(
          '/profile',
          pathParameters: {'nickname': userNickname},
        );
      }
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (showTopButtons)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MapUiButton(
                        onTap: () => _handleFriendsTap(context),
                        icon: Icons.people,
                        heroTag: 'popup_friends_button',
                      ),
                      MapUiButton(
                        onTap: () => _handleProfileTap(context),
                        icon: Icons.person,
                        heroTag: 'popup_profile_button',
                      ),
                    ],
                  ),
                Expanded(
                  child: Align(
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
                        child: child,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
