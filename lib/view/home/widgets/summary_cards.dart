import 'package:flutter/material.dart';
import 'package:hackathon/model/cycling_activity.dart';
import 'package:hackathon/themes/app_constants.dart';

class SummaryCards extends StatelessWidget {
  const SummaryCards({super.key, required this.activities});
  final List<CyclingActivity> activities;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last 90 days summary',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: Spacings.m),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.directions_bike,
                title: 'Rides',
                subtitle: '$count',
              ),
            ),
            const SizedBox(width: Spacings.m),
            Expanded(
              child: _StatTile(
                icon: Icons.access_time,
                title: 'Time',
                subtitle: '${totalHours.toStringAsFixed(1)} h',
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacings.m),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.route,
                title: 'Distance',
                subtitle: '${totalKm.toStringAsFixed(1)} km',
              ),
            ),
            const SizedBox(width: Spacings.m),
            Expanded(
              child: _StatTile(
                icon: Icons.local_fire_department,
                title: 'Energy',
                subtitle: '${totalKcal.toStringAsFixed(0)} kcal',
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacings.m),
        _StatTile(
          icon: Icons.speed,
          title: 'Average speed',
          subtitle: '${avgSpeed.toStringAsFixed(1)} km/h',
        ),
        const SizedBox(height: Spacings.m),
        _StatTile(
          icon: Icons.favorite,
          title: 'Average heart rate',
          subtitle: '${avgHeartRate.toStringAsFixed(0)} bpm',
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile(
      {required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.onSurface,
          width: BorderWidth.m,
        ),
        borderRadius: BorderRadius.circular(Radiuses.s),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacings.m,
          vertical: Spacings.xxs,
        ),
        visualDensity: VisualDensity.compact,
        minLeadingWidth: 0,
        leading: Icon(
          icon,
          color: theme.colorScheme.secondary,
          size: IconSizes.m,
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium,
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.titleMedium,
        ),
        dense: true,
      ),
    );
  }
}
