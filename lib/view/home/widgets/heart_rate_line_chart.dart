import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/model/cycling_activity.dart';
import 'package:hackathon/view/home/widgets/chart_card.dart';

class HeartRateLineChart extends StatelessWidget {
  const HeartRateLineChart(
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

    final List<FlSpot> avgSpots = <FlSpot>[
      for (int i = 0; i < last.length; i++)
        FlSpot(i.toDouble(), (last[i].averageHeartRateBpm ?? 0).toDouble())
    ];
    final List<FlSpot> maxSpots = <FlSpot>[
      for (int i = 0; i < last.length; i++)
        FlSpot(i.toDouble(), (last[i].maxHeartRateBpm ?? 0).toDouble())
    ];

    // Compute subtitle: average of average HR across shown points
    final double avgAvgHr = last.isEmpty
        ? 0
        : last
                .map((a) => (a.averageHeartRateBpm ?? 0).toDouble())
                .fold<double>(0, (p, e) => p + e) /
            last.length;

    return ChartCard(
      title: 'Heart rate (avg & max bpm)',
      subtitle: 'Average: ${avgAvgHr.toStringAsFixed(0)} bpm',
      child: LineChart(
        LineChartData(
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
              spots: avgSpots,
              isCurved: true,
              color: theme.colorScheme.primary,
              barWidth: 3,
              dotData: const FlDotData(show: false),
            ),
            LineChartBarData(
              spots: maxSpots,
              isCurved: true,
              color: theme.colorScheme.error,
              barWidth: 3,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
