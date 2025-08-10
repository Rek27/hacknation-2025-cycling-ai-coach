import 'package:flutter/material.dart';
import 'package:hackathon/dto/cycling_activity_dto.dart';
import 'package:hackathon/services/health_service.dart';
import 'package:hackathon/model/cycling_activity.dart';
import 'package:hackathon/services/export_service.dart';
import 'package:hackathon/model/mock_cycling_data.dart';

/// The HomeController is the controller for the home screen.
///
/// It handles the data loading and mapping for the home screen.
/// It also handles the persistence of the cycling activities.
class HomeController extends ChangeNotifier {
  List<CyclingActivity> last90DayCycling = <CyclingActivity>[];

  HomeController() {
    loadMockCyclingData(count: 6);
  }

  /// Syncs the cycling activities from the health service.
  ///
  /// The activities are fetched from the health service and inserted into the database.
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

  /// Exports the cycling activities as a CSV file and shares it.
  ///
  /// The CSV file is exported and shared with the user.
  Future<void> exportCyclingCsvAndShare() async {
    if (last90DayCycling.isEmpty) return;
    final file = await ExportService.instance
        .exportCyclingCsv(activities: last90DayCycling);
    await ExportService.instance.shareFile(file);
  }

  /// Loads mock cycling data.
  ///
  /// The mock data is generated and added to the list of cycling activities.
  void loadMockCyclingData({int count = 20}) {
    last90DayCycling = generateMockCyclingActivities(count: count);
    notifyListeners();
  }

  /// Adds a cycling activity to the list of cycling activities.
  ///
  /// The activity is inserted into the database.
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
