import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hackathon/model/cycling_activity.dart';

class ExportService {
  ExportService._internal();
  static final ExportService instance = ExportService._internal();

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
