/// Example DTO demonstrating a simple Supabase RPC call.
///
/// Wraps `test_function(p_test_id int)` and returns a typed map from id to name.
import 'package:supabase_flutter/supabase_flutter.dart';

class TestDto {
  /// Call the `test_function` RPC with a numeric id and return `{ id: name }`.
  static Future<Map<int, String>> testFunction({
    required int testId,
  }) async {
    final supabase = Supabase.instance.client;
    try {
      final result = await supabase.rpc<dynamic>('test_function', params: {
        'p_test_id': testId,
      });

      String testName = result[0]['test_name'];

      return {testId: testName};
    } catch (e) {
      throw Exception('Error calling test_function: $e');
    }
  }
}
