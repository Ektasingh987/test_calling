import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/agora/agora_service.dart';
import '../../../../core/constants/env_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/call_log_entity.dart';
import '../cubit/call_cubit.dart';
import '../cubit/call_state.dart';
import '../widgets/call_control_button.dart';

class ActiveCallScreen extends StatefulWidget {
  final String callerName;
  final String? callerAvatar;
  final bool isVideo;

  const ActiveCallScreen({
    super.key,
    required this.callerName,
    this.callerAvatar,
    this.isVideo = true,
  });

  @override
  State<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends State<ActiveCallScreen> {
  int? _remoteUid;
  bool _handlerRegistered = false;
  RtcEngineEventHandler? _eventHandler;

  @override
  void initState() {
    super.initState();
    _setupAgoraHandlers();
  }

  void _setupAgoraHandlers() {
    if (_handlerRegistered || !AgoraService.instance.isInitialized) return;

    _eventHandler = RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        debugPrint('[Agora] Successfully joined channel: ${connection.channelId}');
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        debugPrint('[Agora] Remote user joined: $remoteUid');
        if (mounted) {
          setState(() => _remoteUid = remoteUid);
          context.read<ActiveCallCubit>().onRemoteUserJoined();
        }
      },
      onUserOffline: (connection, remoteUid, reason) {
        debugPrint('[Agora] Remote user offline: $remoteUid, reason: $reason');
        if (mounted) {
          setState(() => _remoteUid = null);
        }
      },
      onError: (err, msg) {
        debugPrint('[Agora Error] $err: $msg');
      },
    );

    try {
      AgoraService.instance.engine.registerEventHandler(_eventHandler!);
      _handlerRegistered = true;
    } catch (_) {}
  }

  @override
  void dispose() {
    if (_handlerRegistered && _eventHandler != null && AgoraService.instance.isInitialized) {
      try {
        AgoraService.instance.engine.unregisterEventHandler(_eventHandler!);
      } catch (_) {}
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActiveCallCubit, ActiveCallState>(
      listener: (context, state) {
        if (state is ActiveCallConnected && !_handlerRegistered) {
          _setupAgoraHandlers();
        }
        if (state is ActiveCallEnded) {
          Navigator.of(context).pop();
        }
      },
      child: BlocBuilder<ActiveCallCubit, ActiveCallState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                // Background gradient / remote stream
                _buildBackground(state),

                // Video views (only in video mode)
                if (widget.isVideo) _buildVideoViews(state),

                // Audio mode avatar (when video is off or audio call)
                if (!widget.isVideo ||
                    (state is ActiveCallConnected && state.isCameraOff))
                  _buildAudioModeView(state),

                // Top overlay: caller info + timer
                _buildTopOverlay(state),

                // Bottom controls
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildControlsToolbar(context, state),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackground(ActiveCallState state) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.callBgGradient,
      ),
    );
  }

  Widget _buildVideoViews(ActiveCallState state) {
    final connectedState = state is ActiveCallConnected ? state : null;
    final connected = connectedState != null;

    return Stack(
      children: [
        // Main remote view
        if (_remoteUid != null)
          AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: AgoraService.instance.engine,
              canvas: VideoCanvas(uid: _remoteUid!),
              connection: RtcConnection(
                channelId: EnvConfig.agoraChannelName,
              ),
            ),
          )
        else
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  color: AppTheme.primary,
                  strokeWidth: 2,
                ),
                const SizedBox(height: 16),
                Text(
                  connected ? 'Waiting for ${widget.callerName}...' : 'Connecting...',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

        // Local camera preview (PiP, top-right)
        if (connected && !connectedState.isCameraOff)
          Positioned(
            top: 100,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 110,
                height: 150,
                child: AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: AgoraService.instance.engine,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAudioModeView(ActiveCallState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                widget.callerName.isNotEmpty
                    ? widget.callerName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 50,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopOverlay(ActiveCallState state) {
    final connectedState = state is ActiveCallConnected ? state : null;
    final elapsed = connectedState?.elapsedSeconds ?? 0;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.callerName,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state is ActiveCallConnecting
                          ? 'Connecting...'
                          : DateFormatter.formatDuration(elapsed),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlsToolbar(BuildContext context, ActiveCallState state) {
    final connectedState = state is ActiveCallConnected ? state : null;
    final isMuted = connectedState?.isMuted ?? false;
    final isCameraOff = connectedState?.isCameraOff ?? false;
    final isSpeakerOn = connectedState?.isSpeakerOn ?? true;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.85),
            Colors.transparent,
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute mic
          CallControlButton(
            icon: Icons.mic_rounded,
            activeIcon: Icons.mic_off_rounded,
            isActive: isMuted,
            label: isMuted ? 'Unmute' : 'Mute',
            onTap: () => context.read<ActiveCallCubit>().toggleMute(),
          ),

          // Speakerphone toggle
          CallControlButton(
            icon: Icons.volume_up_rounded,
            activeIcon: Icons.hearing_rounded,
            isActive: !isSpeakerOn,
            label: isSpeakerOn ? 'Speaker' : 'Earpiece',
            onTap: () => context.read<ActiveCallCubit>().toggleSpeaker(),
          ),

          // Camera toggle (only in video mode)
          if (widget.isVideo)
            CallControlButton(
              icon: Icons.videocam_rounded,
              activeIcon: Icons.videocam_off_rounded,
              isActive: isCameraOff,
              label: isCameraOff ? 'Cam On' : 'Cam Off',
              onTap: () => context.read<ActiveCallCubit>().toggleCamera(),
            ),

          // Switch camera (only in video mode)
          if (widget.isVideo)
            CallControlButton(
              icon: Icons.flip_camera_ios_rounded,
              label: 'Flip',
              onTap: () => context.read<ActiveCallCubit>().switchCamera(),
            ),

          // End call
          CallControlButton(
            icon: Icons.call_end_rounded,
            isDanger: true,
            label: 'End',
            size: 64,
            onTap: () => context.read<ActiveCallCubit>().endCall(
                  status: CallStatus.accepted,
                ),
          ),
        ],
      ),
    );
  }
}

