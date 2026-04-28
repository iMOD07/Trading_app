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
  bool _passVisible = false;
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
    super.dispose();
  }

  void _confirmLogout(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: const Text('Logout', style: TextStyle(color: AppTheme.text1)),
        content: const Text('Are you sure?', style: TextStyle(color: AppTheme.text2)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () { Navigator.pop(ctx); _logout(ctx); },
            child: const Text('Logout', style: TextStyle(color: AppTheme.loss)),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext ctx) async {
    await AuthService.clear();
    if (ctx.mounted) {
      Navigator.pushAndRemoveUntil(ctx,
          MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
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
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ));
            } else if (state is ProfileFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ));
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
                    // User Info Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(children: [
                        const CircleAvatar(
                          backgroundColor: AppTheme.primary,
                          child: Icon(Icons.person, color: Colors.black),
                        ),
                        const SizedBox(width: 12),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(_username, style: const TextStyle(
                              color: AppTheme.text1, fontWeight: FontWeight.bold, fontSize: 16)),
                          const Text('IBKR Paper Trading', style: TextStyle(
                              color: AppTheme.text2, fontSize: 12)),
                        ]),
                      ]),
                    ),
                    const SizedBox(height: 24),

                    // Password
                    const Text('Change Password', style: TextStyle(
                        color: AppTheme.text2, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: !_passVisible,
                      style: const TextStyle(color: AppTheme.text1),
                      decoration: InputDecoration(
                        hintText: 'New password (optional)',
                        suffixIcon: IconButton(
                          icon: Icon(_passVisible ? Icons.visibility_off : Icons.visibility,
                              color: AppTheme.text2, size: 20),
                          onPressed: () => setState(() => _passVisible = !_passVisible),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state is ProfileLoading ? null : () => _submit(context),
                        child: state is ProfileLoading
                            ? const SizedBox(height: 20, width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black))
                            : const Text('Save Changes'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Logout Button
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
    ctx.read<ProfileBloc>().add(ProfileUpdateSubmitted(
      username: _username,
      password: _passwordCtrl.text.trim().isEmpty ? null : _passwordCtrl.text.trim(),
    ));
  }
}
