import 'package:flutter/material.dart';

enum NotificationType {
  newFriendRequest('new_friend_request'),
  friendRequestAccepted('friend_request_accepted'),
  newComment('new_comment'),
  newPost('new_post'),
  unknown('');

  final String value;
  const NotificationType(this.value);

  factory NotificationType.fromString(String? type) {
    if (type == null) return NotificationType.unknown;
    final normalized = type.trim().toLowerCase();

    if (normalized == 'new_friend_request') {
      return NotificationType.newFriendRequest;
    }

    if (normalized == 'friend_request_accepted') {
      return NotificationType.friendRequestAccepted;
    }

    if (normalized == 'new_comment') {
      return NotificationType.newComment;
    }

    if (normalized == 'new_post') {
      return NotificationType.newPost;
    }

    return NotificationType.unknown;
  }

  IconData get icon {
    switch (this) {
      case NotificationType.newFriendRequest:
        return Icons.person_add;
      case NotificationType.friendRequestAccepted:
        return Icons.check_circle;
      case NotificationType.newComment:
        return Icons.draw_sharp;
      case NotificationType.newPost:
        return Icons.image;
      case NotificationType.unknown:
        return Icons.notifications;
    }
  }
}
