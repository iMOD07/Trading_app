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
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _apiKeyCtrl = TextEditingController();
  final _apiSecretCtrl = TextEditingController();

  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final username = await AuthService.getUsername();
    setState(() => _username = username ?? '');
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _apiKeyCtrl.dispose();
    _apiSecretCtrl.dispose();
    super.dispose();
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
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _logout(ctx);
            },
            child: const Text('Logout', style: TextStyle(color: AppTheme.loss)),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext ctx) async {
    await AuthService.clear();
    if (ctx.mounted) {
      Navigator.pushAndRemoveUntil(
        ctx,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: AppTheme.loss),
              onPressed: () => _logout(context),
            ),
          ],
        ),
        body: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is ProfileFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name (display only)
                    Text(
                      'Username: $_username',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),

                    // New Password
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New Password (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Alpaca API Key
                    TextFormField(
                      controller: _apiKeyCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Alpaca API Key',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Alpaca API Secret
                    TextFormField(
                      controller: _apiSecretCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Alpaca API Secret',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state is ProfileLoading
                            ? null
                            : () => _submit(context),
                        child: state is ProfileLoading
                            ? const CircularProgressIndicator()
                            : const Text('Save Changes'),
                      ),
                    ),

                    const SizedBox(height: 16),
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
                        onPressed: () => _confirmLogout(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _submit(BuildContext ctx) {
    ctx.read<ProfileBloc>().add(
          ProfileUpdateSubmitted(
            username: _username,
            password: _passwordCtrl.text.trim(),
            alpacaApiKey: _apiKeyCtrl.text.trim(),
            alpacaApiSecret: _apiSecretCtrl.text.trim(),
          ),
        );
  }
}
