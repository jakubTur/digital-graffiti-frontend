import 'package:flutter/material.dart';
import 'package:frontend/features/friends/domain/repositories/relation_repository.dart';
import 'package:frontend/features/notifications/data/datasources/notifications_remote_data_source.dart';

import '../../auth/data/datasources/auth_storage.dart';
import '../../map/presentation/map_bottom_popup.dart';
import 'notification_list.dart';

class NotificationPopup extends StatelessWidget {
  const NotificationPopup({
    super.key,
    required this.authStorage,
    required this.notificationsDataSource,
    required this.relationRepository,
  });

  final AuthStorage authStorage;
  final NotificationsRemoteDataSource notificationsDataSource;
  final RelationRepository relationRepository;

  @override
  Widget build(BuildContext context) {
    return MapBottomPopup(
      authStorage: authStorage,
      isNotificationsOpen: true,
      child: NotificationList(
        notificationsDataSource: notificationsDataSource,
        relationRepository: relationRepository,
      ),
    );
  }
}
