import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/form_secondary_text.dart';
import 'package:frontend/core/widgets/loading_screen.dart';
import 'package:frontend/core/widgets/popup_text.dart';
import 'package:frontend/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:frontend/features/notifications/data/models/notification_response.dart';
import 'package:frontend/features/notifications/domain/notification_type.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../friends/domain/repositories/relation_repository.dart';
import '../../map/presentation/state/map_model.dart';
import 'notification_card.dart';

class NotificationList extends StatefulWidget {
  const NotificationList({
    super.key,
    required this.notificationsDataSource,
    required this.relationRepository,
  });

  final NotificationsRemoteDataSource notificationsDataSource;

  final RelationRepository relationRepository;

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
    try {
      final loaded = await widget.notificationsDataSource.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = loaded;
          _isLoading = false;
        });
      }
      return;
    } catch (e) {
      debugPrint('Failed to load notifications: $e');
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleNotificationTap(NotificationResponse notification) async {
    if (!notification.read) {
      try {
        await widget.notificationsDataSource.markAsRead(notification.id);
      } catch (e) {
        debugPrint('Failed to mark notification as read: $e');
      }
    }

    if (!mounted) return;

    final type = notification.notificationType;
    final id = int.tryParse(notification.referenceId);

    switch (type) {
      case NotificationType.newFriendRequest:
      case NotificationType.friendRequestAccepted:
        if (id != null) {
          final relation = await widget.relationRepository.getRelation(id);
          if (!mounted) return;
          if (type == NotificationType.newFriendRequest) {
            context.pushNamed(
              '/profile',
              pathParameters: {"nickname": relation.senderNickname},
            );

            context.pushNamed(
              '/profile',
              pathParameters: {"nickname": relation.receiverNickname},
            );
          }
        } else {
          context.pushReplacement('/friends');
        }
        break;

      case NotificationType.newPost:
      case NotificationType.newComment:
        final mapModel = context.read<MapModel>();

        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/map');
        }

        if (id != null) {
          await mapModel.focusOnPostById(id);
        }
        break;

      default:
        _loadNotifications();
        break;
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
                      onTap: () => _handleNotificationTap(notification),
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
