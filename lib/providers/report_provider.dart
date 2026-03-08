import 'package:flutter/material.dart';
import '../services/report_service.dart';
import '../models/report_model.dart';

class ReportProvider extends ChangeNotifier {
  final ReportService _reportService = ReportService();
  ReportModel? _report;
  bool _isLoading = false;

  ReportModel? get report => _report;
  bool get isLoading => _isLoading;

  Future<void> loadReport(int userId, String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _reportService.getWeeklyReport(userId, token);
      _report = ReportModel.fromJson(data);
    } catch (e) {
      _report = null;
    }
    _isLoading = false;
    notifyListeners();
  }
}