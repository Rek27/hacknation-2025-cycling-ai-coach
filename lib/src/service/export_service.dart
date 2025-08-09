import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hackathon/src/model/cycling_activity.dart';

class ExportService {
  ExportService._internal();
  static final ExportService instance = ExportService._internal();

  Future<File> exportStepsCsv({
    required List<int> stepsPerDay,
    required DateTime endDate,
    String fileNamePrefix = 'steps_last_7_days',
  }) async {
    final DateFormat df = DateFormat('yyyy-MM-dd HH:mm:ss');
    final List<List<dynamic>> rows = <List<dynamic>>[
      <String>['date', 'steps'],
    ];

    for (int i = 0; i < stepsPerDay.length; i++) {
      final DateTime day = DateTime(endDate.year, endDate.month, endDate.day)
          .subtract(Duration(days: stepsPerDay.length - 1 - i));
      rows.add(<dynamic>[df.format(day), stepsPerDay[i]]);
    }

    final String csv = const ListToCsvConverter().convert(rows);
    final Directory dir = await getTemporaryDirectory();
    final String path =
        '${dir.path}/$fileNamePrefix-${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
    final File file = File(path);
    await file.writeAsString(csv);
    return file;
  }

  Future<void> shareFile(File file) async {
    await Share.shareXFiles([XFile(file.path)]);
  }

  Future<File> exportCyclingCsv({
    required List<CyclingActivity> activities,
    String fileNamePrefix = 'cycling_last_90_days',
  }) async {
    final List<List<dynamic>> rows = <List<dynamic>>[
      CyclingActivity.csvHeader(),
      ...activities.map((e) => e.toCsvRow()),
    ];
    final String csv = const ListToCsvConverter().convert(rows);
    final Directory dir = await getTemporaryDirectory();
    final String path =
        '${dir.path}/$fileNamePrefix-${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
    final File file = File(path);
    await file.writeAsString(csv);
    return file;
  }
}
