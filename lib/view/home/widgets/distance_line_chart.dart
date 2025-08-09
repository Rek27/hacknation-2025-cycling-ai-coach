import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/model/cycling_activity.dart';
import 'package:hackathon/themes/app_constants.dart';

class DistanceLineChart extends StatelessWidget {
  const DistanceLineChart(
      {super.key, required this.activities, this.maxPoints = 30});

  final List<CyclingActivity> activities;
  final int maxPoints;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<CyclingActivity> data = List<CyclingActivity>.from(activities)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final List<CyclingActivity> last =
        data.length > maxPoints ? data.sublist(data.length - maxPoints) : data;

    final List<FlSpot> spots = <FlSpot>[
      for (int i = 0; i < last.length; i++)
        FlSpot(i.toDouble(), last[i].distanceKm)
    ];

    return _ChartCard(
      title: 'Distance per ride (km)',
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                  '${value.toInt() + 1}', style: theme.textTheme.bodySmall),
            )),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (last.length / 5).clamp(1, 6).toDouble(),
                getTitlesWidget: (value, meta) => Text('${value.toInt() + 1}',
                    style: theme.textTheme.bodySmall),
              ),
            ),
          ),
          borderData: FlBorderData(
              show: true, border: Border.all(color: theme.dividerColor)),
          lineBarsData: <LineChartBarData>[
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: theme.colorScheme.primary,
              barWidth: 3,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacings.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: Spacings.s),
            SizedBox(height: 200, child: child),
          ],
        ),
      ),
    );
  }
}
