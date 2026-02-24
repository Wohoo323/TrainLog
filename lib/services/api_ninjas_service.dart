import 'dart:convert';
import 'package:http/http.dart' as http;

import '../secrets.dart';

class ApiNinjasService {
  static const _baseUrl = 'https://api.api-ninjas.com/v1';

  Future<double?> caloriesBurned({
    required String activity,
    required int durationMinutes,
    required double weightKg,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/caloriesburned'
          '?activity=${Uri.encodeComponent(activity)}'
          '&duration=$durationMinutes'
          '&weight=$weightKg',
    );

    final res = await http.get(uri, headers: {'X-Api-Key': apiNinjasKey});
    if (res.statusCode != 200) return null;

    final data = jsonDecode(res.body);
    if (data is List && data.isNotEmpty) {
      final calories = data.first['total_calories'];
      if (calories is num) return calories.toDouble();
    }
    return null;
  }
}

