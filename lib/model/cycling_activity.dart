class CyclingActivity {
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final double distanceKm;
  final double averageSpeedKmh;
  final double activeEnergyKcal;
  final double? elevationGainMeters;
  final double? averageHeartRateBpm;
  final double? maxHeartRateBpm;
  final double? vo2Max;

  const CyclingActivity({
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.distanceKm,
    required this.averageSpeedKmh,
    required this.activeEnergyKcal,
    this.elevationGainMeters,
    this.averageHeartRateBpm,
    this.maxHeartRateBpm,
    this.vo2Max,
  });

  Map<String, dynamic> toJson() {
    return {
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'duration_seconds': duration.inSeconds,
      'distance_km': distanceKm,
      'avg_speed_kmh': averageSpeedKmh,
      'active_energy_kcal': activeEnergyKcal,
      'elevation_gain_m': elevationGainMeters,
      'avg_hr_bpm': averageHeartRateBpm?.round(),
      'max_hr_bpm': maxHeartRateBpm?.round(),
      'vo2max': vo2Max,
    };
  }

  factory CyclingActivity.fromJson(Map<String, dynamic> json) {
    // print(json);
    return CyclingActivity(
      startTime: DateTime.parse(json['started_at'] as String),
      endTime: DateTime.parse(json['ended_at'] as String),
      duration: Duration(seconds: json['duration_seconds'] as int),
      distanceKm: (json['distance_km'] as num).toDouble(),
      averageSpeedKmh: (json['avg_speed_kmh'] as num).toDouble(),
      activeEnergyKcal: (json['active_energy_kcal'] as num).toDouble(),
      elevationGainMeters: (json['elevation_gain_m'] as num?)?.toDouble(),
      averageHeartRateBpm: (json['avg_hr_bpm'] as num?)?.toDouble(),
      maxHeartRateBpm: (json['max_hr_bpm'] as num?)?.toDouble(),
      vo2Max: (json['vo2max'] as num?)?.toDouble(),
    );
  }

  static List<String> csvHeader() {
    return <String>[
      'start_time',
      'end_time',
      'duration_seconds',
      'distance_km',
      'avg_speed_kmh',
      'active_energy_kcal',
      'elevation_gain_m',
      'avg_hr_bpm',
      'max_hr_bpm',
      'vo2max',
    ];
  }
}
