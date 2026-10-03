import 'package:flutter/material.dart';
import 'guru_dashboard.dart';
import 'guru_manajemen.dart';
import 'guru_validasi.dart';
import 'guru_monitoring.dart';
import '../siswa/clinic_tab.dart';

class GuruHome extends StatefulWidget {
  const GuruHome({super.key});
  @override
  State<GuruHome> createState() => _GuruHomeState();
}

class _GuruHomeState extends State<GuruHome> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    GuruDashboard(),
    GuruManajemen(),
    GuruValidasi(),
    GuruMonitoring(),
    ClinicTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined), label: 'Siswa'),
          BottomNavigationBarItem(
              icon: Icon(Icons.task_alt_outlined), label: 'Validasi'),
          BottomNavigationBarItem(
              icon: Icon(Icons.monitor_heart_outlined), label: 'Monitoring'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bug_report_outlined), label: 'Klinik'),
        ],
      ),
    );
  }
}
