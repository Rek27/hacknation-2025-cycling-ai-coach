import 'package:flutter/material.dart';
import 'package:hackathon/dto/cycling_activity_dto.dart';
import 'package:hackathon/services/health_service.dart';
import 'package:hackathon/model/cycling_activity.dart';
import 'package:hackathon/services/export_service.dart';
import 'package:hackathon/model/mock_cycling_data.dart';

class HomeController extends ChangeNotifier {
  List<CyclingActivity> last90DayCycling = <CyclingActivity>[];

  HomeController() {
    loadMockCyclingData(count: 6);
  }

  Future<bool> syncFromHealth() async {
    final bool granted = await HealthService.instance.requestPermissions(
      readCycling: true,
    );
    if (!granted) return false;

    last90DayCycling +=
        await HealthService.instance.fetchCyclingActivitiesLast90Days();

    // insert into db
    for (var activity in last90DayCycling) {
      await CyclingActivityDto.insertActivity(
        userId: '00000000-0000-0000-0000-000000000000',
        activity: activity,
      );
    }

    notifyListeners();
    return true;
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

  Future<void> addActivity(CyclingActivity activity) async {
    await CyclingActivityDto.insertActivity(
      userId: '00000000-0000-0000-0000-000000000000',
      activity: activity,
    );

    last90DayCycling = List<CyclingActivity>.from(last90DayCycling)
      ..add(activity);
    // keep newest first
    last90DayCycling.sort((a, b) => b.startTime.compareTo(a.startTime));
    notifyListeners();
  }
}
