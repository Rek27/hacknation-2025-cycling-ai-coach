import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hackathon/model/cycling_activity.dart';

class CyclingActivityDto {
  static Future<List<CyclingActivity>> loadActivities({
    required DateTime start,
    required DateTime end,
    String? userId,
    int limit = 1000,
    int offset = 0,
  }) async {
    final supabase = Supabase.instance.client;

    final params = <String, dynamic>{
      'p_start_date_iso': start.toIso8601String(),
      'p_end_date_iso': end.toIso8601String(),
      if (userId != null && userId.isNotEmpty) 'p_user_id': userId,
      'p_limit': limit,
      'p_offset': offset,
    };

    final data = await supabase.rpc<dynamic>('load_cycling_activities', params: params);

    if (data == null) return <CyclingActivity>[];

    final list = (data as List).cast<dynamic>();
    return list
        .map((e) => CyclingActivity.fromJson((e as Map).cast<String, dynamic>()))
        .toList(growable: false);
  }


  static Future<String?> insertActivity({
    required String userId,
    required CyclingActivity activity,
  }) async {
    final supabase = Supabase.instance.client;

    final params = <String, dynamic>{
      'p_user_id': userId,
      'p_start_time': activity.startTime.toIso8601String(),
      'p_end_time': activity.endTime.toIso8601String(),
      'p_duration_seconds': activity.duration.inSeconds,
      'p_distance_km': activity.distanceKm,
      'p_avg_speed_kmh': activity.averageSpeedKmh,
      'p_active_energy_kcal': activity.activeEnergyKcal,
      'p_elevation_gain_m': activity.elevationGainMeters,
      'p_avg_hr_bpm': activity.averageHeartRateBpm?.round(),
      'p_max_hr_bpm': activity.maxHeartRateBpm?.round(),
      'p_vo2max': activity.vo2Max,
    };

    final result = await supabase.rpc<dynamic>('insert_cycling_activity', params: params);
    // RPC returns the new id (uuid). It may already be a String.
    if (result == null) return null;
    return result.toString();
  }
}


