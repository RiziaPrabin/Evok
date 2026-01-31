import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AlertSoundService {
  static final AlertSoundService _instance = AlertSoundService._internal();
  factory AlertSoundService() => _instance;
  AlertSoundService._internal() {
    _initializePlayer();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  // ✅ Initialize player
  void _initializePlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      debugPrint('🎵 Player State: $state');
      if (state == PlayerState.completed) {
        _isPlaying = false;
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      debugPrint('🎵 Playback completed');
    });
  }

  /// Play panic alert sound (loops until stopped)
  Future<void> playPanicAlert() async {
    if (_isPlaying) {
      debugPrint('⚠️ Alert already playing');
      return;
    }

    try {
      debugPrint('🔊 Starting panic alert...');

      _isPlaying = true;

      // Stop any existing playback first
      await _audioPlayer.stop();

      // Set audio mode for alerts (maximum priority)
      await _audioPlayer.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: [
              AVAudioSessionOptions.mixWithOthers,
            ],
          ),
          android: AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.alarm,
            audioFocus: AndroidAudioFocus.gain,
          ),
        ),
      );

      // Set volume to maximum
      await _audioPlayer.setVolume(1.0);

      // Set to loop
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);

      // Play the sound
      await _audioPlayer.play(AssetSource('sounds/Buttonbeep.wav'));

      debugPrint('✅ PANIC ALERT SOUND PLAYING');
    } catch (e, stackTrace) {
      debugPrint('❌ Error playing panic alert: $e');
      debugPrint('Stack trace: $stackTrace');
      _isPlaying = false;
    }
  }

  /// Play a single beep for non-critical alerts
  Future<void> playWarningBeep() async {
    try {
      debugPrint('🔔 Playing warning beep...');
      final beepPlayer = AudioPlayer();
      await beepPlayer.setVolume(0.8);
      await beepPlayer.play(AssetSource('sounds/Buttonbeep.wav'));

      debugPrint('✅ Warning beep played');
    } catch (e) {
      debugPrint('❌ Error playing warning beep: $e');
    }
  }

  /// Stop the alert sound
  Future<void> stopAlert() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      debugPrint('🔇 Alert sound stopped');
    } catch (e) {
      debugPrint('❌ Error stopping alert: $e');
    }
  }

  /// Check if alert is currently playing
  bool get isPlaying => _isPlaying;

  /// Dispose audio player
  void dispose() {
    _audioPlayer.dispose();
  }
}
