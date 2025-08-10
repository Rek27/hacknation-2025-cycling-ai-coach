import 'dart:async';
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

  double _asDouble(dynamic value) {
    // Health package v13 uses typed HealthValue wrappers
    try {
      if (value is num) return value.toDouble();
      // NumericHealthValue from package:health
      // ignore: avoid_dynamic_calls
      final dynamic maybeNumeric = value;
      if (maybeNumeric != null && maybeNumeric is Object) {
        // Try common property names without importing internal classes directly
        // ignore: avoid_dynamic_calls
        final dynamic numeric = (maybeNumeric as dynamic).numericValue;
        if (numeric is num) return numeric.toDouble();
        // Some versions expose .value
        // ignore: avoid_dynamic_calls
        final dynamic val = (maybeNumeric as dynamic).value;
        if (val is num) return val.toDouble();
      }
    } catch (_) {}
    return 0.0;
  }

  Future<bool> requestPermissions({
    bool readCycling = true,
    bool requestWriteAlso = false,
  }) async {
    await configureIfNeeded();

    // Request only READ for supported types; avoid redundant/unsupported combos.
    final List<HealthDataType> types = <HealthDataType>[
      if (readCycling) HealthDataType.WORKOUT,
      if (readCycling) HealthDataType.DISTANCE_CYCLING,
      if (readCycling) HealthDataType.ACTIVE_ENERGY_BURNED,
      if (readCycling) HealthDataType.HEART_RATE,
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

      // Double-check explicit hasPermissions if request flow returns false
      final bool has =
          (await _health.hasPermissions(types, permissions: permissions)) ??
              false;
      if (has) return true;

      // Fallback: open Settings to let user grant manually
      await openAppSettings();
      final bool hasAfter =
          (await _health.hasPermissions(types, permissions: permissions)) ??
              false;
      return hasAfter;
    } catch (e, st) {
      print('Health permission error: $e\n$st');
      rethrow;
    }
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

    // Group data by workout sessions. We'll consider a workout a cycling activity
    // if it contains any DISTANCE_CYCLING samples in its time window.
    final List<HealthDataPoint> workouts = points
        .where((p) => p.type == HealthDataType.WORKOUT)
        .toList(growable: false);

    final List<CyclingActivity> activities = <CyclingActivity>[];

    for (final HealthDataPoint w in workouts) {
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
            distanceMeters += _asDouble(p.value);
            break;
          case HealthDataType.ACTIVE_ENERGY_BURNED:
            energyKcal += _asDouble(p.value);
            break;
          // Cycling speed not available as a dedicated type in this package; derive from distance/duration
          case HealthDataType.HEART_RATE:
            final double v = _asDouble(p.value);
            hrValues.add(v);
            if (maxHr == null || v > maxHr) maxHr = v;
            break;
          default:
            break;
        }
      }

      // Skip workouts with no cycling distance; avoids relying on metadata that may differ across platforms
      if (distanceMeters <= 0) {
        continue;
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
    print('activities: $activities');
    return activities;
  }
}
