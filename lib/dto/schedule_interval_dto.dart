import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/schedule_interval.dart';

abstract class ScheduleIntervalDto {

  static Future<void> insertInterval(
    ScheduleInterval interval,
  ) async {
    final supabase = Supabase.instance.client;

    // Call the Postgres function via Supabase RPC
    print('Inserting schedule interval: ${interval.toJson()}');
    await supabase.rpc<dynamic>(
        'create_schedule_interval',
        params: interval.toJson(),
    );
    return;
  }

  /// Fetch intervals overlapping [start, end) for an optional [userId] and optional [types] filter.
  /// Mock user is used if [userId] is null.
  static Future<List<ScheduleInterval>> readIntervals({
    required DateTime start,
    required DateTime end,
    String? userId,
    List<ScheduleType>? types,
  }) async {
    final supabase = Supabase.instance.client;

    userId ??= '00000000-0000-0000-0000-000000000000';

    final params = <String, dynamic>{
      'p_start': start.toIso8601String(),
      'p_end': end.toIso8601String(),
      // TODO: Use real userId if available
      'p_user_id': userId,
      if (types != null && types.isNotEmpty)
        'p_types': types.map(scheduleTypeToString).toList(), // ['Cycling','Work',...]
    };

    final data = await supabase.rpc<dynamic>('list_schedule_intervals', params: params);
    if (data == null) return <ScheduleInterval>[];

    final rows = (data as List).cast<Map<String, dynamic>>();
    return rows.map(ScheduleInterval.fromJson).toList();
  }
}
