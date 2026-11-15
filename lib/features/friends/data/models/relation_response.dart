import '../../../profile/data/relation_status.dart';

class RelationResponse {
  const RelationResponse({
    required this.senderNickname,
    required this.receiverNickname,
    required this.status,
  });

  final String senderNickname;
  final String receiverNickname;
  final RelationStatus status;

  factory RelationResponse.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? '';
    final status = RelationStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == statusStr.toLowerCase(),
      orElse: () => RelationStatus.none,
    );
    return RelationResponse(
      senderNickname: json['senderNickname'] as String? ?? '',
      receiverNickname: json['receiverNickname'] as String? ?? '',
      status: status,
    );
  }
}
