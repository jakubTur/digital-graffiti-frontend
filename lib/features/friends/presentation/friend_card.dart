import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/form_secondary_text.dart';
import 'package:frontend/core/widgets/user_avatar.dart';
import 'package:frontend/features/auth/data/models/user_response.dart';
import 'package:go_router/go_router.dart';

class FriendCard extends StatelessWidget {
  const FriendCard({required this.response, super.key});

  final UserResponse response;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: InkWell(
        child: Row(
          children: [
            UserAvatar(imageUrl: response.imageUrl),
            Spacer(),
            FormSecondaryText(response.nickname),
            Spacer(),
          ],
        ),
        onTap: () {
          context.pushNamed(
            '/profile',
            pathParameters: {'nickname': response.nickname},
          );
        },
      ),
    );
  }
}
