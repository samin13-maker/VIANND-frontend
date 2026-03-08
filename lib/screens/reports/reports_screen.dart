import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../../widgets/bottom_nav.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    if (auth.user != null && auth.token != null) {
      await context.read<ReportProvider>().loadReport(auth.user!.id, auth.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();
    final report = reportProvider.report;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 16),
            color: Colors.black87,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Mis reportes', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                Icon(Icons.notifications_outlined, color: Colors.white),
              ],
            ),
          ),
          Expanded(
            child: reportProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Reporte Semanal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              ElevatedButton.icon(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4CAF50),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                icon: const Icon(Icons.download, color: Colors.white, size: 16),
                                label: const Text('Descargar', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _nutrientCard('${report?.avgProtein.toInt() ?? 0}g', 'Proteína'),
                              const SizedBox(width: 12),
                              _nutrientCard('${report?.avgCarbs.toInt() ?? 0}g', 'Carbos'),
                              const SizedBox(width: 12),
                              _nutrientCard('${report?.avgFat.toInt() ?? 0}g', 'Grasas'),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildBarChart(report?.dailyCalories ?? []),
                          const SizedBox(height: 20),
                          _buildComplianceCard(report?.compliancePercent ?? 0),
                          const SizedBox(height: 20),
                          const Text('Datos clave', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                            ),
                            child: Row(
                              children: [
                                Expanded(child: _keyData('${report?.compliancePercent.toInt() ?? 0}%', 'Cumplimiento', Icons.percent)),
                                Expanded(child: _keyData('${report?.avgCalories.toInt() ?? 0}', 'Prom. kcal/día', Icons.local_fire_department)),
                                Expanded(child: _keyData('${report?.totalExtras ?? 0}', 'Extras/semana', Icons.warning_amber)),
                                Expanded(child: _keyData('${report?.consecutiveDays ?? 0}', 'Días consecutivos', Icons.calendar_today)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 3),
    );
  }

  Widget _nutrientCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(List<Map<String, dynamic>> dailyData) {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final maxCal = dailyData.isEmpty ? 200.0 : dailyData.map((d) => (d['calories'] as num).toDouble()).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Calorías Totales', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (i) {
                final cal = i < dailyData.length ? (dailyData[i]['calories'] as num).toDouble() : 0.0;
                final height = maxCal > 0 ? (cal / maxCal * 120) : 0.0;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 28,
                      height: height,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF9A9A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(days[i], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceCard(double percent) {
    Color statusColor;
    String statusText;
    if (percent >= 80) {
      statusColor = const Color(0xFF4CAF50);
      statusText = '¡Excelente cumplimiento!';
    } else if (percent >= 50) {
      statusColor = Colors.orange;
      statusText = 'Buen progreso';
    } else {
      statusColor = Colors.red;
      statusText = 'Necesitas mejorar';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percent / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
                Text('${percent.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(width: 20),
          const VerticalDivider(width: 1),
          const SizedBox(width: 20),
          Column(
            children: [
              Icon(Icons.traffic, size: 36, color: statusColor),
              const SizedBox(height: 8),
              Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _keyData(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10), textAlign: TextAlign.center),
      ],
    );
  }
}