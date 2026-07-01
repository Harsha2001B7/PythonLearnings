import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../core/models/trailer.dart';
import 'trailer_player_state.dart';

class TrailerPlayerController extends ChangeNotifier {
  TrailerPlayerController(Trailer trailer, {bool initialMuted = false})
    : _youtubeController = _createYoutubeController(
        trailer,
        initialMuted: initialMuted,
      ),
      _state = TrailerPlayerState(trailer: trailer, isMuted: initialMuted) {
    _bindController();
  }

  static YoutubePlayerController _createYoutubeController(
    Trailer trailer, {
    required bool initialMuted,
  }) {
    return YoutubePlayerController.fromVideoId(
      videoId: trailer.youtubeVideoId,
      autoPlay: true,
      params: YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: false,
        mute: initialMuted,
        playsInline: true,
        enableCaption: true,
        strictRelatedVideos: true,
      ),
    );
  }

  YoutubePlayerController _youtubeController;
  YoutubePlayerController get youtubeController => _youtubeController;

  TrailerPlayerState _state;
  TrailerPlayerState get state => _state;

  StreamSubscription<YoutubePlayerValue>? _playerSubscription;
  StreamSubscription<YoutubeVideoState>? _videoStateSubscription;
  bool _disposed = false;

  Future<void> replaceTrailer(Trailer trailer) async {
    if (_disposed || trailer.id == _state.trailer.id) return;
    final wasMuted = _state.isMuted;
    await _disposeYoutubeController();
    _youtubeController = _createYoutubeController(
      trailer,
      initialMuted: wasMuted,
    );
    _state = TrailerPlayerState(trailer: trailer, isMuted: wasMuted);
    _bindController();
    notifyListeners();
  }

  void _bindController() {
    _playerSubscription = _youtubeController.stream.listen(_handlePlayerValue);
    _videoStateSubscription = _youtubeController.videoStateStream.listen(
      _handleVideoState,
    );
    _syncMuteState();
  }

  void _handlePlayerValue(YoutubePlayerValue value) {
    if (_disposed) return;
    final playerState = value.playerState;
    final duration = value.metaData.duration;
    final isFullscreen = value.fullScreenOption.enabled;

    _state = _state.copyWith(
      isPlaying: playerState == PlayerState.playing,
      isBuffering: playerState == PlayerState.buffering,
      isFullscreen: isFullscreen,
      duration: duration > Duration.zero ? duration : _state.duration,
    );
    notifyListeners();
  }

  void _handleVideoState(YoutubeVideoState value) {
    if (_disposed) return;
    _state = _state.copyWith(
      position: value.position,
      loadedFraction: value.loadedFraction.clamp(0, 1),
    );
    notifyListeners();
  }

  Future<void> _syncMuteState() async {
    try {
      final muted = await _youtubeController.isMuted;
      if (_disposed) return;
      _state = _state.copyWith(isMuted: muted);
      notifyListeners();
    } catch (_) {
      // The iframe may not be ready yet; the explicit toggle path keeps state
      // correct once the user interacts with audio.
    }
  }

  Future<void> togglePlayback() async {
    if (_state.isPlaying) {
      await _youtubeController.pauseVideo();
    } else {
      await _youtubeController.playVideo();
    }
  }

  Future<void> seekTo(Duration position) async {
    final seconds = position.inMilliseconds / Duration.millisecondsPerSecond;
    _state = _state.copyWith(position: position);
    notifyListeners();
    await _youtubeController.seekTo(seconds: seconds, allowSeekAhead: true);
  }

  Future<void> toggleMute() async {
    final nextMuted = !_state.isMuted;
    _state = _state.copyWith(isMuted: nextMuted);
    notifyListeners();
    if (nextMuted) {
      await _youtubeController.mute();
    } else {
      await _youtubeController.unMute();
    }
  }

  Future<void> enterFullscreen() async {
    if (_state.isFullscreen) return;
    _youtubeController.enterFullScreen();
    await _applySystemChrome(true);
  }

  Future<void> exitFullscreen() async {
    if (!_state.isFullscreen) return;
    _youtubeController.exitFullScreen();
    await _applySystemChrome(false);
  }

  Future<void> restorePortraitChrome() => _applySystemChrome(false);

  Future<void> _applySystemChrome(bool fullscreen) async {
    if (fullscreen) {
      await SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      return;
    }

    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  Future<void> _disposeYoutubeController() async {
    await _playerSubscription?.cancel();
    await _videoStateSubscription?.cancel();
    _playerSubscription = null;
    _videoStateSubscription = null;
    try {
      await _youtubeController.close();
    } catch (_) {}
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    unawaited(restorePortraitChrome());
    unawaited(_disposeYoutubeController());
    super.dispose();
  }
}
