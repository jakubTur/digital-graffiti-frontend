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
}
