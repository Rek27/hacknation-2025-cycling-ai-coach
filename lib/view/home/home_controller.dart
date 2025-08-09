import 'package:flutter/material.dart';
import 'package:hackathon/services/health_service.dart';
import 'package:hackathon/model/cycling_activity.dart';
import 'package:hackathon/services/export_service.dart';
import 'package:hackathon/model/mock_cycling_data.dart';

class HomeController extends ChangeNotifier {
  List<int> last7DaySteps = List<int>.filled(7, 0);
  List<CyclingActivity> last90DayCycling = <CyclingActivity>[];

  Future<void> syncFromHealth() async {
    final bool granted = await HealthService.instance.requestPermissions(
      readCycling: true,
    );
    if (!granted) return;

    last7DaySteps = await HealthService.instance.fetchStepsPerDay(days: 7);
    last90DayCycling =
        await HealthService.instance.fetchCyclingActivitiesLast90Days();

    notifyListeners();
  }

  Future<void> exportCyclingCsvAndShare() async {
    if (last90DayCycling.isEmpty) return;
    final file = await ExportService.instance
        .exportCyclingCsv(activities: last90DayCycling);
    await ExportService.instance.shareFile(file);
  }

  void loadMockCyclingData({int count = 20}) {
    last90DayCycling = generateMockCyclingActivities(count: count);
    notifyListeners();
  }
}
