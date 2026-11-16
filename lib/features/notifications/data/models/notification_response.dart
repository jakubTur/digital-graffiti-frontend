
class NotificationResponse {
  final String id;
  final String title;
  final String body;
  final String type;
  final String referenceId;
  final bool read;

  const NotificationResponse({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.referenceId,
    required this.read,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: json['type'] as String? ?? '',
      referenceId: json['referenceId'].toString(),
      read: json['read'] as bool? ?? false,
    );
  }
}