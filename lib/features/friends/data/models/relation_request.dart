import '../../domain/entities/relation_status.dart';

class RelationRequest {
  const RelationRequest({
    required this.senderId,
    required this.receiverId,
    required this.status,
  });

  final int senderId;
  final int receiverId;
  final RelationStatus status;

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'type': status.name,
    };
  }
}
