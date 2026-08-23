import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/call_log_model.dart';

abstract class CallLocalDataSource {
  Future<List<CallLogModel>> getCallHistory();
  Future<void> saveCallLog(CallLogModel model);
  Future<void> deleteCallLog(String id);
  Future<void> clearHistory();
}

class CallLocalDataSourceImpl implements CallLocalDataSource {
  Box<CallLogModel> get _box =>
      Hive.box<CallLogModel>(AppConstants.callLogsBox);

  @override
  Future<List<CallLogModel>> getCallHistory() async {
    try {
      final logs = _box.values.toList();
      // Sort newest first
      logs.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return logs;
    } catch (e) {
      throw CacheException(message: 'Failed to load call history: $e');
    }
  }

  @override
  Future<void> saveCallLog(CallLogModel model) async {
    try {
      await _box.put(model.id, model);
    } catch (e) {
      throw CacheException(message: 'Failed to save call log: $e');
    }
  }

  @override
  Future<void> deleteCallLog(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw CacheException(message: 'Failed to delete call log: $e');
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      await _box.clear();
    } catch (e) {
      throw CacheException(message: 'Failed to clear call history: $e');
    }
  }
}

