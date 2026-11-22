import 'package:frontend/features/friends/data/models/relation_nickname_request.dart';
import 'package:frontend/features/friends/data/models/relation_request.dart';
import 'package:frontend/features/friends/data/models/relation_response.dart';

import '../../domain/entities/relation_status.dart';
import '../../domain/repositories/relation_repository.dart';
import '../datasources/relations_remote_ds.dart';

class RelationRepositoryImpl extends RelationRepository {
  RelationRepositoryImpl(this.remoteDataSource);

  final RelationsRemoteDataSource remoteDataSource;

  @override
  Future<void> createRelation(RelationRequest request) async {
    return await remoteDataSource.createRelation(request);
  }

  @override
  Future<void> createRelationByNicknames(
    RelationNicknameRequest request,
  ) async {
    return await remoteDataSource.createByNicknames(request);
  }

  @override
  Future<RelationResponse> getRelationByIds(int firstId, int secondId) async {
    return await remoteDataSource.getRelation(firstId, secondId);
  }

  @override
  Future<RelationResponse> getRelationByNicknames(
    String firstNickname,
    String secondNickname,
  ) async {
    return await remoteDataSource.getRelationByNickname(
      firstNickname,
      secondNickname,
    );
  }

  @override
  Future<List<RelationResponse>> getRelations(
    int id,
    RelationStatus type,
  ) async {
    return await remoteDataSource.getRelations(id, type.name);
  }

  @override
  Future<void> deleteRelation(
    String firstNickname,
    String secondNickname,
  ) async {
    return await remoteDataSource.deleteRelation(firstNickname, secondNickname);
  }

  @override
  Future<void> updateRelation(RelationNicknameRequest request) async {
    return await remoteDataSource.updateRelation(request);
  }
}
