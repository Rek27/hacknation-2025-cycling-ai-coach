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

    print('Schedule interval inserted successfully');

    // var result = await supabase.rpc<dynamic>(
    //         'test_function',
    //         params: {
    //           'p_test_id': 123,
    //         }
    //     );
    //
    // print(result);
    return;
  }
}
