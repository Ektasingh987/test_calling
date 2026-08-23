import 'package:equatable/equatable.dart';

enum CallType { audio, video }

enum CallStatus { missed, accepted, rejected }

class CallLogEntity extends Equatable {
  final String id;
  final String callerName;
  final String? callerAvatar;
  final CallType callType;
  final CallStatus callStatus;
  final int durationSeconds;
  final DateTime dateTime;

  const CallLogEntity({
    required this.id,
    required this.callerName,
    this.callerAvatar,
    required this.callType,
    required this.callStatus,
    required this.durationSeconds,
    required this.dateTime,
  });

  @override
  List<Object?> get props => [
        id,
        callerName,
        callerAvatar,
        callType,
        callStatus,
        durationSeconds,
        dateTime,
      ];
}

