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
}
