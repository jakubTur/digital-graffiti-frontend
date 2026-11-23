import 'package:flutter/material.dart';

import '../data/models/notification_response.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.notification, this.onTap});

  final NotificationResponse notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: notification.read
              ? Colors.grey.shade200
              : Colors.deepPurple.shade100,
          width: 1,
        ),
      ),
      color: notification.read ? Colors.white : Colors.deepPurple.shade50,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: notification.read
                    ? Colors.grey.shade100
                    : Colors.deepPurple.shade100,
                child: Icon(
                  notification.notificationType.icon,
                  color: notification.read
                      ? Colors.grey.shade600
                      : Colors.deepPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: notification.read
                            ? FontWeight.normal
                            : FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              if (!notification.read) ...[
                const SizedBox(width: 8.0),
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
