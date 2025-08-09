import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:hackathon/model/cycling_activity.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthService {
  HealthService._internal();
  static final HealthService instance = HealthService._internal();

  final Health _health = Health();
  bool _configured = false;

  Future<void> configureIfNeeded() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  Future<bool> requestPermissions({
    bool readCycling = true,
    bool requestWriteAlso = false,
  }) async {
    await configureIfNeeded();

    final List<HealthDataType> types = <HealthDataType>[
      if (readCycling) HealthDataType.DISTANCE_CYCLING,
      if (readCycling) HealthDataType.ACTIVE_ENERGY_BURNED,
      if (readCycling) HealthDataType.HEART_RATE,
      if (readCycling) HealthDataType.WORKOUT,
    ];

    final List<HealthDataAccess> permissions = types
        .map((_) => requestWriteAlso
            ? HealthDataAccess.READ_WRITE
            : HealthDataAccess.READ)
        .toList(growable: false);

    try {
      final bool granted = await _health.requestAuthorization(
        types,
        permissions: permissions,
      );
      if (granted) return true;
      // Fallback: open Settings to let user grant manually in prototype flows
      await openAppSettings();
      final bool has =
          (await _health.hasPermissions(types, permissions: permissions)) ??
              false;
      return has;
    } catch (e, st) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Health permission error: $e\n$st');
      }
      return false;
    }
  }

  Future<List<int>> fetchStepsPerDay({int days = 7}) async {
    await configureIfNeeded();
    final DateTime now = DateTime.now();
    final List<int> results = <int>[];
    for (int i = days - 1; i >= 0; i--) {
      final DateTime dayStart =
          DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final DateTime dayEnd = dayStart.add(const Duration(days: 1));
      try {
        final int? steps = await _health.getTotalStepsInInterval(
          dayStart,
          dayEnd,
        );
        results.add(steps ?? 0);
      } catch (e, st) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('Steps fetch error for $dayStart: $e\n$st');
        }
        results.add(0);
      }
    }
    return results;
  }

  Future<List<CyclingActivity>> fetchCyclingActivitiesLast90Days() async {
    await configureIfNeeded();
    final DateTime now = DateTime.now();
    final DateTime start = now.subtract(const Duration(days: 90));

    final List<HealthDataType> types = <HealthDataType>[
      HealthDataType.WORKOUT,
      HealthDataType.DISTANCE_CYCLING,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.HEART_RATE,
    ];

    // Make sure we have permissions
    final bool ok = await requestPermissions(readCycling: true);
    if (!ok) return <CyclingActivity>[];

    final List<HealthDataPoint> points = await _health.getHealthDataFromTypes(
      startTime: start,
      endTime: now,
      types: types,
    );

    // Group data by workout sessions (cycling only)
    // The health package exposes WORKOUT samples with metadata fields.
    final List<HealthDataPoint> workouts = points
        .where((p) => p.type == HealthDataType.WORKOUT)
        .toList(growable: false);

    final List<CyclingActivity> activities = <CyclingActivity>[];

    for (final HealthDataPoint w in workouts) {
      final String valueStr = w.value.toString().toLowerCase();
      final Map<String, dynamic>? meta = w.metadata;
      final String? metaA = meta?['HKWorkoutActivityType']?.toString();
      final String? metaB = meta?['workoutActivityType']?.toString();
      final bool isCycling = valueStr.contains('cycling') ||
          (metaA?.toLowerCase().contains('cycling') ?? false) ||
          (metaB?.toLowerCase().contains('cycling') ?? false);
      if (!isCycling) continue;

      final DateTime startTime = w.dateFrom;
      final DateTime endTime = w.dateTo;
      final Duration duration = endTime.difference(startTime);

      // Filter points within this workout window
      bool within(DateTime d) => !d.isBefore(startTime) && !d.isAfter(endTime);

      double distanceMeters = 0.0;
      double energyKcal = 0.0;
      double? elevationGain = 0.0;
      final List<double> speedValues = <double>[];
      final List<double> hrValues = <double>[];
      double? maxHr;
      double? vo2;

      for (final HealthDataPoint p in points) {
        if (!within(p.dateFrom) && !within(p.dateTo)) continue;
        switch (p.type) {
          case HealthDataType.DISTANCE_CYCLING:
            distanceMeters += (p.value as num).toDouble();
            break;
          case HealthDataType.ACTIVE_ENERGY_BURNED:
            energyKcal += (p.value as num).toDouble();
            break;
          // Cycling speed not available as a dedicated type in this package; derive from distance/duration
          case HealthDataType.HEART_RATE:
            final double v = (p.value as num).toDouble();
            hrValues.add(v);
            if (maxHr == null || v > maxHr) maxHr = v;
            break;
          default:
            break;
        }
      }

      final double distanceKm = distanceMeters / 1000.0;
      // If we have instantaneous speeds (m/s), compute average; otherwise derive from distance/duration
      double avgSpeedKmh;
      if (speedValues.isNotEmpty) {
        final double avgMs =
            speedValues.reduce((a, b) => a + b) / speedValues.length;
        avgSpeedKmh = avgMs * 3.6;
      } else {
        avgSpeedKmh = duration.inSeconds > 0
            ? (distanceMeters / duration.inSeconds) * 3.6
            : 0.0;
      }

      final double? avgHr = hrValues.isNotEmpty
          ? hrValues.reduce((a, b) => a + b) / hrValues.length
          : null;

      activities.add(CyclingActivity(
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        distanceKm: distanceKm,
        averageSpeedKmh: avgSpeedKmh,
        activeEnergyKcal: energyKcal,
        elevationGainMeters: elevationGain,
        averageHeartRateBpm: avgHr,
        maxHeartRateBpm: maxHr,
        vo2Max: vo2,
      ));
    }

    // Sort by start time descending
    activities.sort((a, b) => b.startTime.compareTo(a.startTime));
    return activities;
  }
}
