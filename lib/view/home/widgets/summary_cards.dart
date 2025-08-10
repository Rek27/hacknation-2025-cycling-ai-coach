import 'package:flutter/material.dart';
import 'package:hackathon/model/cycling_activity.dart';
import 'package:hackathon/themes/app_constants.dart';

class SummaryCards extends StatelessWidget {
  const SummaryCards({super.key, required this.activities});
  final List<CyclingActivity> activities;

  @override
  Widget build(BuildContext context) {
    final int count = activities.length;
    final double totalKm = activities.fold(0.0, (p, e) => p + e.distanceKm);
    final double totalHours =
        activities.fold(0.0, (p, e) => p + e.duration.inMinutes / 60.0);
    final double totalKcal =
        activities.fold(0.0, (p, e) => p + e.activeEnergyKcal);
    final double avgSpeed = count > 0
        ? activities.fold(0.0, (p, e) => p + e.averageSpeedKmh) / count
        : 0.0;

    // Average heart rate across activities that have it
    final List<double> heartRates = activities
        .map((a) => a.averageHeartRateBpm)
        .where((hr) => hr != null)
        .cast<double>()
        .toList();
    final double avgHeartRate = heartRates.isNotEmpty
        ? heartRates.reduce((a, b) => a + b) / heartRates.length
        : 0.0;

    final List<_StatCard> items = <_StatCard>[
      _StatCard(title: 'Rides', value: '$count'),
      _StatCard(title: 'Distance', value: '${totalKm.toStringAsFixed(1)} km'),
      _StatCard(title: 'Time', value: '${totalHours.toStringAsFixed(1)} h'),
      _StatCard(title: 'Energy', value: '${totalKcal.toStringAsFixed(0)} kcal'),
      _StatCard(
          title: 'Avg speed', value: '${avgSpeed.toStringAsFixed(1)} km/h'),
      _StatCard(
          title: 'Avg HR', value: '${avgHeartRate.toStringAsFixed(0)} bpm'),
    ];

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: Spacings.m),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: Spacings.s,
        mainAxisSpacing: Spacings.s,
        childAspectRatio: 2.1,
      ),
      itemBuilder: (BuildContext context, int index) => items[index],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacings.s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.bodyMedium),
            const SizedBox(height: Spacings.s),
            Text(value,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
