/// Noise preset for the Dark Room.
class NoisePreset {
  final NoiseType type;
  final double volume; // 0.0 - 1.0

  const NoisePreset({
    required this.type,
    this.volume = 0.3,
  });

  NoisePreset copyWith({
    NoiseType? type,
    double? volume,
  }) {
    return NoisePreset(
      type: type ?? this.type,
      volume: volume ?? this.volume,
    );
  }
}

enum NoiseType {
  white,
  brown,
  pink,
  off;

  String get displayName {
    switch (this) {
      case NoiseType.white:
        return 'White Noise';
      case NoiseType.brown:
        return 'Brown Noise';
      case NoiseType.pink:
        return 'Pink Noise';
      case NoiseType.off:
        return 'Off';
    }
  }

  String get description {
    switch (this) {
      case NoiseType.white:
        return 'Equal intensity across all frequencies. Great for masking sharp sounds.';
      case NoiseType.brown:
        return 'Deeper, rumbling sound like wind or a waterfall. Most relaxing for sleep.';
      case NoiseType.pink:
        return 'Balanced between white and brown. Mimics natural sounds like rain.';
      case NoiseType.off:
        return 'Silence.';
    }
  }
}
