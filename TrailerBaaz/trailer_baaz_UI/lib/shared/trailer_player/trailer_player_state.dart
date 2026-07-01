import '../../core/models/trailer.dart';

class TrailerPlayerState {
  const TrailerPlayerState({
    required this.trailer,
    this.isPlaying = false,
    this.isBuffering = false,
    this.isMuted = false,
    this.isFullscreen = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.loadedFraction = 0,
  });

  final Trailer trailer;
  final bool isPlaying;
  final bool isBuffering;
  final bool isMuted;
  final bool isFullscreen;
  final Duration position;
  final Duration duration;
  final double loadedFraction;

  TrailerPlayerState copyWith({
    Trailer? trailer,
    bool? isPlaying,
    bool? isBuffering,
    bool? isMuted,
    bool? isFullscreen,
    Duration? position,
    Duration? duration,
    double? loadedFraction,
  }) {
    return TrailerPlayerState(
      trailer: trailer ?? this.trailer,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      isMuted: isMuted ?? this.isMuted,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      loadedFraction: loadedFraction ?? this.loadedFraction,
    );
  }
}
