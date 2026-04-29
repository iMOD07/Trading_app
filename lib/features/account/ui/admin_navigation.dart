import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import 'admin_screen.dart';
import '../../profile/ui/profile_screen.dart';

class AdminNavigation extends StatefulWidget {
  const AdminNavigation({super.key});
  @override
  State<AdminNavigation> createState() => _AdminNavigationState();
}

class _AdminNavigationState extends State<AdminNavigation> {
  int _index = 0;

  final _screens = const [
    AdminScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppTheme.gold,
          unselectedItemColor: AppTheme.text2,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.admin_panel_settings),
                label: 'Manage Users'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
