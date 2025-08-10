import 'package:flutter/material.dart';
import 'package:hackathon/themes/app_constants.dart';
import 'package:hackathon/view/home/widgets/ai_chat.dart';
import 'package:hackathon/view/home/widgets/distance_line_chart.dart';
import 'package:hackathon/view/home/widgets/energy_bar_chart.dart';
import 'package:hackathon/view/home/widgets/heart_rate_line_chart.dart';
import 'package:hackathon/view/home/widgets/speed_line_chart.dart';
import 'package:hackathon/view/home/widgets/summary_cards.dart';
import 'package:hackathon/view/scheduler/scheduler_view.dart';
import 'package:provider/provider.dart';
import 'package:hackathon/view/home/home_controller.dart';

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
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Calendar',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SchedulerView()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.import_export),
            tooltip: 'Sync last 90 days',
            onPressed: () async {
              final success = await controller.syncFromHealth();

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Synced data successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to sync data')),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            ListView(
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
                const SizedBox(height: 120),
              ],
            ),
            // Overlay AI chat in bottom-right, free from FAB constraints
            Positioned(
              right: Spacings.m,
              bottom: Spacings.m,
              child: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: 360,
                  height: 400,
                  child: const AIChat(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
