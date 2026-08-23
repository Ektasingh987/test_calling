import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/agora/agora_service.dart';
import '../../../../core/utils/permission_helper.dart';
import '../../domain/entities/call_log_entity.dart';
import '../../domain/usecases/call_usecases.dart';
import 'call_state.dart';

// ─── Call History Cubit ──────────────────────────────────────────────────────

class CallHistoryCubit extends Cubit<CallHistoryState> {
  final GetCallHistoryUseCase _getHistory;

  CallHistoryCubit({required GetCallHistoryUseCase getHistoryUseCase})
      : _getHistory = getHistoryUseCase,
        super(const CallHistoryInitial());

  Future<void> loadHistory() async {
    if (isClosed) return;
    emit(const CallHistoryLoading());
    final result = await _getHistory();
    if (isClosed) return;
    result.fold(
      (failure) => emit(CallHistoryError(failure.message)),
      (logs) => emit(CallHistoryLoaded(logs)),
    );
  }
}

// ─── Active Call Cubit ───────────────────────────────────────────────────────

class ActiveCallCubit extends Cubit<ActiveCallState> {
  final SaveCallLogUseCase _saveCallLog;
  final AgoraService _agora;

  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isVideo = true;
  String _callerName = '';
  bool _isEnding = false;

  ActiveCallCubit({
    required SaveCallLogUseCase saveCallLogUseCase,
    AgoraService? agoraService,
  })  : _saveCallLog = saveCallLogUseCase,
        _agora = agoraService ?? AgoraService.instance,
        super(const ActiveCallInitial());

  /// Called when user accepts or starts an outgoing/incoming call
  Future<void> startCall({
    required String callerName,
    required bool isVideo,
    String? channelName,
  }) async {
    if (isClosed) return;
    _callerName = callerName;
    _isVideo = isVideo;

    // Request permissions first (audio & camera if video, audio only if voice)
    final hasPermissions = await PermissionHelper.requestCallPermissions();
    if (!hasPermissions) {
      if (!isClosed) emit(const ActiveCallEnded(0));
      return;
    }

    if (isClosed) return;
    emit(const ActiveCallConnecting());

    try {
      // Initialize Agora engine with appropriate video/audio mode
      await _agora.init(isVideo: isVideo);

      // Join channel
      await _agora.joinChannel(
        channelName: channelName,
        isVideo: isVideo,
      );

      if (!isClosed) {
        emit(ActiveCallConnected(
          isRemoteJoined: false,
          isCameraOff: !isVideo,
          isSpeakerOn: true,
        ));
        _startTimer();
      }
    } catch (e) {
      if (!isClosed) emit(const ActiveCallEnded(0));
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isClosed) {
        _timer?.cancel();
        return;
      }
      _elapsedSeconds++;
      if (state is ActiveCallConnected && !isClosed) {
        emit((state as ActiveCallConnected)
            .copyWith(elapsedSeconds: _elapsedSeconds));
      }
    });
  }

  Future<void> toggleMute() async {
    if (isClosed || state is! ActiveCallConnected) return;
    final current = state as ActiveCallConnected;
    final newMuted = !current.isMuted;
    try {
      await _agora.muteLocalAudio(mute: newMuted);
    } catch (_) {}
    if (!isClosed && state is ActiveCallConnected) {
      emit((state as ActiveCallConnected).copyWith(isMuted: newMuted));
    }
  }

  Future<void> toggleCamera() async {
    if (isClosed || state is! ActiveCallConnected) return;
    final current = state as ActiveCallConnected;
    final newOff = !current.isCameraOff;
    try {
      await _agora.muteLocalVideo(mute: newOff);
    } catch (_) {}
    if (!isClosed && state is ActiveCallConnected) {
      emit((state as ActiveCallConnected).copyWith(isCameraOff: newOff));
    }
  }

  Future<void> toggleSpeaker() async {
    if (isClosed || state is! ActiveCallConnected) return;
    final current = state as ActiveCallConnected;
    final newSpeaker = !current.isSpeakerOn;
    try {
      await _agora.setSpeakerphone(enabled: newSpeaker);
    } catch (_) {}
    if (!isClosed && state is ActiveCallConnected) {
      emit((state as ActiveCallConnected).copyWith(isSpeakerOn: newSpeaker));
    }
  }

  Future<void> switchCamera() async {
    if (isClosed) return;
    try {
      await _agora.switchCamera();
    } catch (_) {}
  }

  void onRemoteUserJoined() {
    if (!isClosed && state is ActiveCallConnected) {
      emit((state as ActiveCallConnected).copyWith(isRemoteJoined: true));
    }
  }

  Future<void> endCall({required CallStatus status}) async {
    if (_isEnding) return;
    _isEnding = true;
    _timer?.cancel();
    final duration = _elapsedSeconds;

    try {
      await _agora.leaveChannel();
    } catch (_) {}

    // Save call log
    await _saveCallLog(CallLogEntity(
      id: const Uuid().v4(),
      callerName: _callerName,
      callType: _isVideo ? CallType.video : CallType.audio,
      callStatus: status,
      durationSeconds: duration,
      dateTime: DateTime.now(),
    ));

    if (!isClosed) {
      emit(ActiveCallEnded(duration));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
