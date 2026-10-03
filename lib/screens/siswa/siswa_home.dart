import 'package:flutter/material.dart';
import 'showcase_tab.dart';
import 'clinic_tab.dart';
import 'leaderboard_tab.dart';
import 'profile_tab.dart';

class SiswaHome extends StatefulWidget {
  const SiswaHome({super.key});
  @override
  State<SiswaHome> createState() => _SiswaHomeState();
}

class _SiswaHomeState extends State<SiswaHome> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ShowcaseTab(),
    ClinicTab(),
    LeaderboardTab(),
    ProfileTab(),
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
              icon: Icon(Icons.grid_view_rounded), label: 'Showcase'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bug_report_outlined), label: 'Klinik'),
          BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard_outlined), label: 'Peringkat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}
