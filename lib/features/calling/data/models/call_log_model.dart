import 'package:hive/hive.dart';
import '../../domain/entities/call_log_entity.dart';
import '../../../../core/constants/app_constants.dart';

part 'call_log_model.g.dart';

@HiveType(typeId: AppConstants.callLogModelTypeId)
class CallLogModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String callerName;

  @HiveField(2)
  final String? callerAvatar;

  @HiveField(3)
  final int callType; // 0 = audio, 1 = video

  @HiveField(4)
  final int callStatus; // 0 = missed, 1 = accepted, 2 = rejected

  @HiveField(5)
  final int durationSeconds;

  @HiveField(6)
  final DateTime dateTime;

  CallLogModel({
    required this.id,
    required this.callerName,
    this.callerAvatar,
    required this.callType,
    required this.callStatus,
    required this.durationSeconds,
    required this.dateTime,
  });

  factory CallLogModel.fromEntity(CallLogEntity entity) {
    return CallLogModel(
      id: entity.id,
      callerName: entity.callerName,
      callerAvatar: entity.callerAvatar,
      callType: entity.callType.index,
      callStatus: entity.callStatus.index,
      durationSeconds: entity.durationSeconds,
      dateTime: entity.dateTime,
    );
  }

  CallLogEntity toEntity() => CallLogEntity(
        id: id,
        callerName: callerName,
        callerAvatar: callerAvatar,
        callType: CallType.values[callType],
        callStatus: CallStatus.values[callStatus],
        durationSeconds: durationSeconds,
        dateTime: dateTime,
      );
}

