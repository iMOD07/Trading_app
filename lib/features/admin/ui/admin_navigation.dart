import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import '../../../services/auth_service.dart';
import '../../login/ui/login_screen.dart';
import 'admin_screen.dart';

class AdminNavigation extends StatelessWidget {
  const AdminNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          Icon(Icons.admin_panel_settings, color: AppTheme.gold, size: 20),
          SizedBox(width: 8),
          Text('Admin Panel'),
        ]),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.loss),
            tooltip: 'Logout',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: const AdminScreen(),
    );
  }

  void _confirmLogout(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: const Text('Logout', style: TextStyle(color: AppTheme.text1)),
        content: const Text('Are you sure?',
            style: TextStyle(color: AppTheme.text2)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.clear();
              if (ctx.mounted) {
                Navigator.pushAndRemoveUntil(
                    ctx,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false);
              }
            },
            child: const Text('Logout', style: TextStyle(color: AppTheme.loss)),
          ),
        ],
      ),
    );
  }
}
