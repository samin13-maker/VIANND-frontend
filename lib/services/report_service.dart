import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ReportService {
  Future<Map<String, dynamic>> getWeeklyReport(int userId, String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/reports/weekly/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return jsonDecode(response.body);
  }
}