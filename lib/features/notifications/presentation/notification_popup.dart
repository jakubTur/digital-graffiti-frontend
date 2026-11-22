import 'package:flutter/material.dart';
import 'package:frontend/core/storage/auth_storage.dart';
import 'package:frontend/features/notifications/data/datasources/notifications_remote_data_source.dart';

import '../../map/presentation/map_bottom_popup.dart';
import 'notification_list.dart';

class NotificationPopup extends StatelessWidget {
  const NotificationPopup({
    super.key,
    required this.authStorage,
    required this.notificationsDataSource,
  });

  final AuthStorage authStorage;
  final NotificationsRemoteDataSource notificationsDataSource;

  @override
  Widget build(BuildContext context) {
    return MapBottomPopup(
      authStorage: authStorage,
      isNotificationsOpen: true,
      child: NotificationList(notificationsDataSource: notificationsDataSource),
    );
  }
}
