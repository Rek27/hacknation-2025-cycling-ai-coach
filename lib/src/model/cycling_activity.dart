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

  List<String> toCsvRow() {
    return <String>[
      startTime.toIso8601String(),
      endTime.toIso8601String(),
      duration.inSeconds.toString(),
      distanceKm.toStringAsFixed(3),
      averageSpeedKmh.toStringAsFixed(2),
      activeEnergyKcal.toStringAsFixed(1),
      (elevationGainMeters ?? 0).toStringAsFixed(1),
      (averageHeartRateBpm ?? 0).toStringAsFixed(0),
      (maxHeartRateBpm ?? 0).toStringAsFixed(0),
      (vo2Max ?? 0).toStringAsFixed(1),
    ];
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
