import 'package:frontend/features/friends/data/models/relation_request.dart';
import 'package:frontend/features/friends/data/models/relation_response.dart';

import '../../../profile/data/relation_status.dart';
import '../../domain/repository/relation_repository.dart';
import '../datasources/relations_remote_ds.dart';

class RelationRepositoryImpl extends RelationRepository {
  RelationRepositoryImpl(this.remoteDataSource);

  final RelationsRemoteDataSource remoteDataSource;

  @override
  Future<void> createRelation(RelationRequest request) async {
    return await remoteDataSource.createRelation(request);
  }

  @override
  Future<RelationResponse> getRelation(int firstId, int secondId) async {
    return await remoteDataSource.getRelation(firstId, secondId);
  }

  @override
  Future<List<RelationResponse>> getRelations(
    int id,
    RelationStatus type,
  ) async {
    return await remoteDataSource.getRelations(id, type.name);
  }
}
