import '../../data/models/relation_nickname_request.dart';
import '../../data/models/relation_request.dart';
import '../../data/models/relation_response.dart';
import '../entities/relation_status.dart';

abstract class RelationRepository {
  Future<void> createRelation(RelationRequest request);
  Future<List<RelationResponse>> getRelations(int id, RelationStatus type);
  Future<RelationResponse> getRelationByIds(int firstId, int secondId);
  Future<RelationResponse> getRelationByNicknames(
    String firstNickname,
    String secondNickname,
  );
  Future<void> deleteRelation(String firstNickname, String secondNickname);
  Future<void> updateRelation(RelationNicknameRequest request);
  Future<void> createRelationByNicknames(RelationNicknameRequest request);
  Future<RelationResponse> getRelation(int id);
}
