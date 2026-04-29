import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'order/ui/order_screen.dart';
import 'trades/ui/trades_screen.dart';
import 'account/ui/account_screen.dart';
import 'settings/ui/settings_screen.dart';
import 'profile/ui/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  final _screens = const [
    OrderScreen(),
    TradesScreen(),
    AccountScreen(), // = IBKR connection diagnostic
    SettingsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
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
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.text2,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline), label: 'Order'),
            BottomNavigationBarItem(
                icon: Icon(Icons.list_alt), label: 'Trades'),
            BottomNavigationBarItem(
                icon: Icon(Icons.cable), label: 'Connection'),
            BottomNavigationBarItem(icon: Icon(Icons.tune), label: 'Settings'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
