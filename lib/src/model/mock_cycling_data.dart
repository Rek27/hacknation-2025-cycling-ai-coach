import 'dart:math';

import 'package:hackathon/src/model/cycling_activity.dart';

List<CyclingActivity> generateMockCyclingActivities({
  int count = 20,
  DateTime? endTime,
}) {
  final Random rng = Random(42);
  final DateTime end = endTime ?? DateTime.now();

  final List<CyclingActivity> items = <CyclingActivity>[];
  for (int i = 0; i < count; i++) {
    // Spread activities over the past 60 days
    final int daysAgo = rng.nextInt(60);
    final int startHour = 6 + rng.nextInt(12); // morning to evening
    final DateTime start = DateTime(end.year, end.month, end.day)
        .subtract(Duration(days: daysAgo))
        .add(Duration(hours: startHour, minutes: rng.nextInt(60)));

    // Duration between 1h and 4h
    final Duration duration = Duration(minutes: 60 + rng.nextInt(180));
    final DateTime finish = start.add(duration);

    // Distance 20–80 km
    final double distanceKm = 20 + rng.nextDouble() * 60;

    // Average speed derived from distance and duration
    final double avgSpeedKmh =
        duration.inMinutes > 0 ? distanceKm / (duration.inMinutes / 60.0) : 0.0;

    // Energy 500–2000 kcal
    final double kcal = 500 + rng.nextDouble() * 1500;

    // Elevation gain 200–1500 m
    final double elevation = 200 + rng.nextDouble() * 1300;

    // HR avg 120–170, max 160–195
    final double avgHr = 120 + rng.nextDouble() * 50;
    final double maxHr = max(avgHr + 20, 160 + rng.nextDouble() * 35);

    // VO2Max 45–60
    final double vo2 = 45 + rng.nextDouble() * 15;

    items.add(CyclingActivity(
      startTime: start,
      endTime: finish,
      duration: duration,
      distanceKm: distanceKm,
      averageSpeedKmh: avgSpeedKmh,
      activeEnergyKcal: kcal,
      elevationGainMeters: elevation,
      averageHeartRateBpm: avgHr,
      maxHeartRateBpm: maxHr,
      vo2Max: vo2,
    ));
  }

  items.sort((a, b) => b.startTime.compareTo(a.startTime));
  return items;
}
