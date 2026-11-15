import '../../../profile/data/relation_status.dart';

class RelationNicknameRequest {
  const RelationNicknameRequest({
    required this.senderNickname,
    required this.receiverNickname,
    required this.status,
  });

  final String senderNickname;
  final String receiverNickname;
  final RelationStatus status;

  Map<String, dynamic> toJson() {
    return {
      'senderNickname': senderNickname,
      'receiverNickname': receiverNickname,
      'type': status.name,
    };
  }
}
