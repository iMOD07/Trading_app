import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trading_app/app_theme.dart';
import '../../../services/auth_service.dart';
import '../bloc/profile_bloc.dart';
import '../../login/ui/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = '';
  String _role = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final username = await AuthService.getUsername();
    final role = await AuthService.getRole();
    if (mounted) {
      setState(() {
        _username = username ?? '';
        _role = role;
      });
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: const Text('Logout', style: TextStyle(color: AppTheme.text1)),
        content: const Text('Are you sure?',
            style: TextStyle(color: AppTheme.text2)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.clear();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                    context,
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

  @override
  Widget build(BuildContext context) {
    // ProfileBloc kept for compatibility; can be removed once UI is finalized.
    return BlocProvider(
      create: (_) => ProfileBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                    child: Text(
                      _username.isNotEmpty ? _username[0].toUpperCase() : '?',
                      style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_username,
                            style: const TextStyle(
                                color: AppTheme.text1,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: (_role == 'ADMIN'
                                    ? AppTheme.gold
                                    : AppTheme.primary)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(_role,
                              style: TextStyle(
                                  color: _role == 'ADMIN'
                                      ? AppTheme.gold
                                      : AppTheme.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 20),

              // Info note
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Row(children: [
                  Icon(Icons.info_outline, color: AppTheme.text2, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'To change password or IBKR settings, please contact admin.',
                      style: TextStyle(color: AppTheme.text2, fontSize: 12),
                    ),
                  ),
                ]),
              ),
              const Spacer(),

              // Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.loss,
                    side: const BorderSide(color: AppTheme.loss),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _confirmLogout,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
