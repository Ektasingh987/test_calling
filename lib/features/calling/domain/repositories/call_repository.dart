import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/call_log_entity.dart';

abstract class CallRepository {
  Future<Either<Failure, List<CallLogEntity>>> getCallHistory();
  Future<Either<Failure, Unit>> saveCallLog(CallLogEntity callLog);
  Future<Either<Failure, Unit>> deleteCallLog(String id);
  Future<Either<Failure, Unit>> clearCallHistory();
}

