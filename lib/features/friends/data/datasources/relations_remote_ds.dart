import 'package:frontend/features/friends/data/models/relation_nickname_request.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/relation_status.dart';
import '../models/relation_request.dart';
import '../models/relation_response.dart';

class RelationsRemoteDataSource {
  final ApiClient api;
  RelationsRemoteDataSource(this.api);

  Future<void> createRelation(RelationRequest request) async {
    await api.post('/api/relations', body: request.toJson());
  }

  Future<List<RelationResponse>> getRelations(int id, String type) async {
    final response = await api.get('/api/relations/$id/$type');
    if (response == null) return [];
    return (response as List)
        .map(
          (e) => RelationResponse.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  Future<RelationResponse> getRelation(int firstId, int secondId) async {
    final response = await api.get('/api/relations/between/$firstId/$secondId');
    if (response == null) {
      return const RelationResponse(
        senderNickname: '',
        receiverNickname: '',
        status: RelationStatus.none,
      );
    }
    return RelationResponse.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  }

  Future<RelationResponse> getRelationByNickname(
    String firstNickname,
    String secondNickname,
  ) async {
    final response = await api.get(
      '/api/relations/between/nicknames/$firstNickname/$secondNickname',
    );
    if (response == null) {
      return RelationResponse(
        senderNickname: firstNickname,
        receiverNickname: secondNickname,
        status: RelationStatus.none,
      );
    }
    return RelationResponse.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  }

  Future<void> deleteRelation(
    String firstNickname,
    String secondNickname,
  ) async {
    await api.delete('/api/relations/$firstNickname/$secondNickname');
  }

  Future<void> createByNicknames(RelationNicknameRequest request) async {
    await api.post('/api/relations/nicknames', body: request.toJson());
  }

  Future<void> updateRelation(RelationNicknameRequest request) async {
    await api.put('/api/relations', body: request.toJson());
  }
}
