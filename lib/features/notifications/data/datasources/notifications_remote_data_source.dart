import 'package:frontend/core/network/api_client.dart';

import '../models/notification_response.dart';

class NotificationsRemoteDataSource {
  final ApiClient api;
  NotificationsRemoteDataSource(this.api);

  Future<void> registerDeviceToken(String token) async {
    await api.post(
      '/api/users/fire',
      body: {'token': token},
      expectedStatusCode: 200,
    );
  }

  Future<List<NotificationResponse>> getNotifications() async {
    final response = await api.get('/api/notifications');
    if (response is! List) {
      throw const FormatException('Get notifications response is not a list');
    }
    return response
        .map(
          (item) => NotificationResponse.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<void> markAsRead(String notificationId) async {
    await api.patch(
      '/api/notifications/$notificationId/read',
      body: const {},
      expectedStatusCode: 204,
    );
  }
}
