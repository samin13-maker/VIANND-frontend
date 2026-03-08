import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/reminder_service.dart';
import '../../models/reminder_model.dart';
import '../../widgets/bottom_nav.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final _reminderService = ReminderService();
  List<ReminderModel> _reminders = [];
  bool _isLoading = true;

  final _mealTypeNames = {1: 'Desayuno', 2: 'Comida', 3: 'Cena', 4: 'Colación'};
  final _mealTypeIcons = {1: Icons.coffee, 2: Icons.restaurant, 3: Icons.nightlight, 4: Icons.cookie};
  final _mealTypeColors = {
    1: const Color(0xFFFFF8E1),
    2: const Color(0xFFE8F5E9),
    3: const Color(0xFFEDE7F6),
    4: const Color(0xFFFFEBEE),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReminders());
  }

  Future<void> _loadReminders() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null || auth.token == null) return;
    setState(() => _isLoading = true);
    try {
      final data = await _reminderService.getRemindersByUser(auth.user!.id, auth.token!);
      setState(() => _reminders = data.map((r) => ReminderModel.fromJson(r)).toList());
    } catch (e) {
      setState(() => _reminders = []);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _toggleReminder(int id) async {
    final auth = context.read<AuthProvider>();
    await _reminderService.toggleReminder(id, auth.token!);
    await _loadReminders();
  }

  Future<void> _createDefaultReminders() async {
    final auth = context.read<AuthProvider>();
    final defaults = [
      {'userId': auth.user!.id, 'mealType': 1, 'time': '08:00', 'active': true},
      {'userId': auth.user!.id, 'mealType': 2, 'time': '14:00', 'active': true},
      {'userId': auth.user!.id, 'mealType': 3, 'time': '20:00', 'active': true},
      {'userId': auth.user!.id, 'mealType': 4, 'time': '00:00', 'active': false},
    ];
    for (final r in defaults) {
      await _reminderService.createReminder(r, auth.token!);
    }
    await _loadReminders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 16),
            color: Colors.black87,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.go('/profile'),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Recordatorios', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const Spacer(),
                const Icon(Icons.notifications_outlined, color: Colors.white),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : _reminders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Sin recordatorios', style: TextStyle(color: Colors.white)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _createDefaultReminders,
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
                              child: const Text('Crear recordatorios', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _reminders.length,
                        itemBuilder: (_, i) {
                          final r = _reminders[i];
                          final name = _mealTypeNames[r.mealType] ?? '';
                          final icon = _mealTypeIcons[r.mealType] ?? Icons.alarm;
                          final color = _mealTypeColors[r.mealType] ?? Colors.grey[200]!;
                          final timeDisplay = r.time.isEmpty || r.time == '00:00' ? 'Sin hora' : r.time;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                                  child: Icon(icon, color: Colors.black54),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                                      Text(timeDisplay, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: r.active,
                                  onChanged: (_) => _toggleReminder(r.id),
                                  activeColor: const Color(0xFF4CAF50),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Editar alarma', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 4),
    );
  }
}