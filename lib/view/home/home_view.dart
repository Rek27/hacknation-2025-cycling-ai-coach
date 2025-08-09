import 'package:flutter/material.dart';
import 'package:hackathon/themes/app_constants.dart';
import 'package:hackathon/view/home/widgets/distance_line_chart.dart';
import 'package:hackathon/view/home/widgets/energy_bar_chart.dart';
import 'package:hackathon/view/home/widgets/heart_rate_line_chart.dart';
import 'package:hackathon/view/home/widgets/speed_line_chart.dart';
import 'package:hackathon/view/home/widgets/summary_cards.dart';
import 'package:provider/provider.dart';
import 'package:hackathon/view/home/home_controller.dart';
import 'package:hackathon/view/home/ai_chat.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomeController>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cycling Coach'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sync last 90 days',
            onPressed: () => controller.syncFromHealth(),
          ),
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: 'Export CSV',
            onPressed: () => controller.exportCyclingCsvAndShare(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Spacings.m),
          children: [
            SummaryCards(activities: controller.last90DayCycling),
            SizedBox(height: Spacings.m),
            DistanceLineChart(activities: controller.last90DayCycling),
            SizedBox(height: Spacings.m),
            SpeedLineChart(activities: controller.last90DayCycling),
            SizedBox(height: Spacings.m),
            EnergyBarChart(
              activities: controller.last90DayCycling,
              sampleEvery: 2,
            ),
            SizedBox(height: Spacings.m),
            HeartRateLineChart(activities: controller.last90DayCycling),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        height: 450,
        child: AIChat(),
      ),
    );
  }
}
