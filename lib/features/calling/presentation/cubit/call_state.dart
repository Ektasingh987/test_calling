import 'package:equatable/equatable.dart';
import '../../domain/entities/call_log_entity.dart';

// ─── Call History State ──────────────────────────────────────────────────────

abstract class CallHistoryState extends Equatable {
  const CallHistoryState();
  @override
  List<Object?> get props => [];
}

class CallHistoryInitial extends CallHistoryState {
  const CallHistoryInitial();
}

class CallHistoryLoading extends CallHistoryState {
  const CallHistoryLoading();
}

class CallHistoryLoaded extends CallHistoryState {
  final List<CallLogEntity> logs;
  const CallHistoryLoaded(this.logs);
  @override
  List<Object?> get props => [logs];
}

class CallHistoryError extends CallHistoryState {
  final String message;
  const CallHistoryError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── Active Call State ───────────────────────────────────────────────────────

abstract class ActiveCallState extends Equatable {
  const ActiveCallState();
  @override
  List<Object?> get props => [];
}

class ActiveCallInitial extends ActiveCallState {
  const ActiveCallInitial();
}

class ActiveCallConnecting extends ActiveCallState {
  const ActiveCallConnecting();
}

class ActiveCallConnected extends ActiveCallState {
  final bool isMuted;
  final bool isCameraOff;
  final bool isSpeakerOn;
  final bool isRemoteJoined;
  final int elapsedSeconds;

  const ActiveCallConnected({
    this.isMuted = false,
    this.isCameraOff = false,
    this.isSpeakerOn = true,
    this.isRemoteJoined = false,
    this.elapsedSeconds = 0,
  });

  ActiveCallConnected copyWith({
    bool? isMuted,
    bool? isCameraOff,
    bool? isSpeakerOn,
    bool? isRemoteJoined,
    int? elapsedSeconds,
  }) {
    return ActiveCallConnected(
      isMuted: isMuted ?? this.isMuted,
      isCameraOff: isCameraOff ?? this.isCameraOff,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      isRemoteJoined: isRemoteJoined ?? this.isRemoteJoined,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }

  @override
  List<Object?> get props =>
      [isMuted, isCameraOff, isSpeakerOn, isRemoteJoined, elapsedSeconds];
}

class ActiveCallEnded extends ActiveCallState {
  final int durationSeconds;
  const ActiveCallEnded(this.durationSeconds);
  @override
  List<Object?> get props => [durationSeconds];
}
