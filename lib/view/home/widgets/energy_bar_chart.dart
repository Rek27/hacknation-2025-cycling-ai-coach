import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/model/cycling_activity.dart';
import 'package:hackathon/themes/app_constants.dart';

class EnergyBarChart extends StatelessWidget {
  const EnergyBarChart({
    super.key,
    required this.activities,
    this.maxBars = 20,
    this.sampleEvery = 1,
  });

  final List<CyclingActivity> activities;
  final int maxBars;
  final int sampleEvery;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<CyclingActivity> data = List<CyclingActivity>.from(activities)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final List<CyclingActivity> last =
        data.length > maxBars ? data.sublist(data.length - maxBars) : data;

    final int step = sampleEvery <= 0 ? 1 : sampleEvery;
    final List<BarChartGroupData> groups = <BarChartGroupData>[];
    for (int i = 0; i < last.length; i += step) {
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: <BarChartRodData>[
            BarChartRodData(
              toY: last[i].activeEnergyKcal,
              color: theme.colorScheme.tertiary,
              width: 10,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      );
    }

    return _ChartCard(
      title: 'Active energy per ride (kcal)',
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text('${value.toInt() + 1}',
                  style: theme.textTheme.bodySmall),
            )),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: step.toDouble(),
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt() + 1}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
          ),
          borderData: FlBorderData(
              show: true, border: Border.all(color: theme.dividerColor)),
          barGroups: groups,
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
