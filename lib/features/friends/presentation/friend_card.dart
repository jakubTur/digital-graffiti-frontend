import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/user_avatar.dart';
import 'package:frontend/features/auth/data/models/user_response.dart';
import 'package:go_router/go_router.dart';

class FriendCard extends StatelessWidget {
  const FriendCard({required this.response, super.key});

  final UserResponse response;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.pushNamed(
            '/profile',
            pathParameters: {'nickname': response.nickname},
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
          child: Row(
            children: [
              UserAvatar(imageUrl: response.imageUrl, size: 50.0),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      response.nickname,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (response.bio.isNotEmpty) ...[
                      const SizedBox(height: 2.0),
                      Text(
                        response.bio,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.deepPurple.shade300,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
