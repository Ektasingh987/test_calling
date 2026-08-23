import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../constants/env_config.dart';

class AgoraService {
  AgoraService._();

  static final AgoraService instance = AgoraService._();

  RtcEngine? _engine;
  RtcEngine get engine {
    assert(_engine != null, 'AgoraService not initialized. Call init() first.');
    return _engine!;
  }

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// Initialize the Agora RTC engine with the App ID from .env
  Future<void> init({bool isVideo = true}) async {
    if (_initialized && _engine != null) {
      if (isVideo) {
        await _engine!.enableVideo();
        await _engine!.setVideoEncoderConfiguration(
          const VideoEncoderConfiguration(
            dimensions: VideoDimensions(width: 640, height: 360),
            frameRate: 15,
            bitrate: 600,
          ),
        );
      } else {
        await _engine!.disableVideo();
      }
      await _engine!.enableAudio();
      return;
    }

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(
      RtcEngineContext(
        appId: EnvConfig.agoraAppId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    await _engine!.enableAudio();

    if (isVideo) {
      await _engine!.enableVideo();
      await _engine!.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 640, height: 360),
          frameRate: 15,
          bitrate: 600,
        ),
      );
    } else {
      await _engine!.disableVideo();
    }

    // Set default audio route to speakerphone before joining channel
    try {
      await _engine!.setDefaultAudioRouteToSpeakerphone(true);
    } catch (_) {}

    _initialized = true;
  }

  /// Join a channel with the token from .env
  Future<void> joinChannel({
    String? channelName,
    int uid = 0,
    bool isVideo = true,
  }) async {
    if (isVideo) {
      try {
        await engine.startPreview();
      } catch (_) {}
    }

    await engine.joinChannel(
      token: EnvConfig.agoraToken,
      channelId: channelName ?? EnvConfig.agoraChannelName,
      uid: uid,
      options: ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
        publishCameraTrack: isVideo,
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
        autoSubscribeVideo: isVideo,
      ),
    );

    // Enable speakerphone after joining
    try {
      await engine.setEnableSpeakerphone(true);
    } catch (_) {}
  }

  /// Leave channel and clean up
  Future<void> leaveChannel() async {
    try {
      await engine.stopPreview();
    } catch (_) {}
    try {
      await engine.leaveChannel();
    } catch (_) {}
  }

  /// Toggle local microphone
  Future<void> muteLocalAudio({required bool mute}) async {
    await engine.muteLocalAudioStream(mute);
  }

  /// Toggle local camera
  Future<void> muteLocalVideo({required bool mute}) async {
    await engine.muteLocalVideoStream(mute);
  }

  /// Toggle speakerphone (loudspeaker vs earpiece)
  Future<void> setSpeakerphone({required bool enabled}) async {
    try {
      await engine.setEnableSpeakerphone(enabled);
    } catch (_) {}
  }

  /// Switch between front and back camera
  Future<void> switchCamera() async {
    await engine.switchCamera();
  }

  /// Dispose engine resources
  Future<void> dispose() async {
    if (!_initialized) return;
    try {
      await _engine?.stopPreview();
      await _engine?.leaveChannel();
      await _engine?.release();
    } catch (_) {}
    _engine = null;
    _initialized = false;
  }
}
