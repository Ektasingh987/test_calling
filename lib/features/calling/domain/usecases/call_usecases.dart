import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/call_log_entity.dart';
import '../repositories/call_repository.dart';

class GetCallHistoryUseCase {
  final CallRepository repository;
  GetCallHistoryUseCase(this.repository);

  Future<Either<Failure, List<CallLogEntity>>> call() =>
      repository.getCallHistory();
}

class SaveCallLogUseCase {
  final CallRepository repository;
  SaveCallLogUseCase(this.repository);

  Future<Either<Failure, Unit>> call(CallLogEntity callLog) =>
      repository.saveCallLog(callLog);
}

class DeleteCallLogUseCase {
  final CallRepository repository;
  DeleteCallLogUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String id) =>
      repository.deleteCallLog(id);
}

class ClearCallHistoryUseCase {
  final CallRepository repository;
  ClearCallHistoryUseCase(this.repository);

  Future<Either<Failure, Unit>> call() =>
      repository.clearCallHistory();
}
