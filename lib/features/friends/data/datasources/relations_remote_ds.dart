import 'package:frontend/features/friends/data/models/relation_nickname_request.dart';

import '../../../../core/network/api_client.dart';
import '../models/relation_request.dart';
import '../models/relation_response.dart';

class RelationsRemoteDataSource {
  final ApiClient _api;
  RelationsRemoteDataSource(this._api);

  Future<void> createRelation(RelationRequest request) async {
    _api.post('/api/relations', body: request.toJson());
  }

  Future<List<RelationResponse>> getRelations(int id, String type) async {
    return await _api.get('/api/relations/$id/$type');
  }

  Future<RelationResponse> getRelation(int firstId, int secondId) async {
    return await _api.get('/api/relations/between/$firstId/$secondId');
  }

  Future<RelationResponse> getRelationByNickname(
    String firstNickname,
    String secondNickname,
  ) async {
    return await _api.get(
      '/api/relations/between/nicknames/$firstNickname/$secondNickname',
    );
  }

  Future<void> deleteRelation(
    String firstNickname,
    String secondNickname,
  ) async {
    return await _api.delete('/api/relations/$firstNickname/$secondNickname');
  }

  Future<void> createByNicknames(RelationNicknameRequest request) async {
    return await _api.post('/api/relations/nicknames', body: request.toJson());
  }

  Future<void> updateRelation(RelationNicknameRequest request) async {
    return await _api.put('/api/relations', body: request.toJson());
  }
}
