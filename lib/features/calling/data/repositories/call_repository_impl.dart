import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/call_log_entity.dart';
import '../../domain/repositories/call_repository.dart';
import '../datasources/call_local_datasource.dart';
import '../models/call_log_model.dart';

class CallRepositoryImpl implements CallRepository {
  final CallLocalDataSource localDataSource;

  CallRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<CallLogEntity>>> getCallHistory() async {
    try {
      final models = await localDataSource.getCallHistory();
      return Right(models.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveCallLog(CallLogEntity callLog) async {
    try {
      await localDataSource.saveCallLog(CallLogModel.fromEntity(callLog));
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCallLog(String id) async {
    try {
      await localDataSource.deleteCallLog(id);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearCallHistory() async {
    try {
      await localDataSource.clearHistory();
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}

