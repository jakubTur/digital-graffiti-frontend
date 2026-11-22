import 'package:flutter/material.dart';
import 'package:frontend/features/auth/data/datasources/auth_storage.dart';
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

  void _popToMap(BuildContext context) {
    while (context.canPop()) {
      context.pop();
    }
  }

  Future<void> _handleFriendsTap(BuildContext context) async {
    if (isFriendsOpen) {
      _popToMap(context);
    } else {
      _popToMap(context);
      context.push('/friends');
    }
  }

  Future<void> _handleProfileTap(BuildContext context) async {
    final userNickname = await authStorage.readNickname();
    if (!context.mounted || userNickname == null) return;

    if (!isFriendsOpen && currentNickname == userNickname) {
      _popToMap(context);
    } else {
      _popToMap(context);
      context.pushNamed('/profile', pathParameters: {'nickname': userNickname});
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
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
