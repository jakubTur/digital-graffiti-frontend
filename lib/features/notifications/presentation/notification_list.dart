import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/form_secondary_text.dart';
import 'package:frontend/core/widgets/loading_screen.dart';
import 'package:frontend/core/widgets/popup_text.dart';
import 'package:frontend/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:frontend/features/notifications/data/models/notification_response.dart';
import 'package:go_router/go_router.dart';

import 'notification_card.dart';

class NotificationList extends StatefulWidget {
  const NotificationList({super.key, this.notificationsDataSource});

  final NotificationsRemoteDataSource? notificationsDataSource;

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  bool _isLoading = true;
  List<NotificationResponse> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (widget.notificationsDataSource != null) {
      try {
        final loaded = await widget.notificationsDataSource!.getNotifications();
        if (mounted) {
          setState(() {
            _notifications = loaded;
            _isLoading = false;
          });
        }
        return;
      } catch (e) {}
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const LoadingScreen()
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/map');
                        }
                      },
                      iconSize: 40,
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ],
                ),
                const PopupText('Notifications'),
                const SizedBox(height: 16.0),
                if (_notifications.isNotEmpty)
                  ..._notifications.map(
                    (notification) => NotificationCard(
                      notification: notification,
                      onTap: () async {
                        if (!notification.read &&
                            widget.notificationsDataSource != null) {
                          await widget.notificationsDataSource!.markAsRead(
                            notification.id,
                          );
                          _loadNotifications();
                        }
                      },
                    ),
                  )
                else ...[
                  const SizedBox(height: 20),
                  Center(
                    child: FormSecondaryText(
                      'You have no notifications',
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          );
  }
}
