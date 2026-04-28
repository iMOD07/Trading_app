import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app_theme.dart';
import '../../login/bloc/login_bloc.dart';
import 'admin_navigation.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _visible = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(),
      child: BlocConsumer<LoginBloc, LoginState>(
        listener: (ctx, state) {
          if (state is LoginSuccess) {
            Navigator.pushReplacement(
              ctx,
              MaterialPageRoute(
                builder: (_) => const AdminNavigation(),
              ),
            );
          }
          if (state is LoginFailure) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.loss,
              behavior: SnackBarBehavior.floating,
            ));
          }
        },
        builder: (ctx, state) {
          final isLoading = state is LoginLoading;

          return Scaffold(
            backgroundColor: AppTheme.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.text2),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Admin logo ──
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.gold.withValues(alpha: 0.1),
                          border: Border.all(color: AppTheme.gold, width: 2),
                        ),
                        child: const Icon(Icons.admin_panel_settings,
                            color: AppTheme.gold, size: 44),
                      ),
                      const SizedBox(height: 24),
                      const Text('Admin Panel',
                          style: TextStyle(
                              color: AppTheme.text1,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      const Text('Restricted access',
                          style:
                              TextStyle(color: AppTheme.text2, fontSize: 13)),
                      const SizedBox(height: 32),

                      // ── Username ──
                      TextField(
                        controller: _userCtrl,
                        style: const TextStyle(color: AppTheme.text1),
                        decoration: InputDecoration(
                          labelText: 'Admin Username',
                          prefixIcon: const Icon(Icons.person_outline,
                              color: AppTheme.text2, size: 20),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppTheme.gold, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ── Password ──
                      TextField(
                        controller: _passCtrl,
                        obscureText: !_visible,
                        onSubmitted: (_) => _submit(ctx),
                        style: const TextStyle(color: AppTheme.text1),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: AppTheme.text2, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                                _visible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppTheme.text2,
                                size: 20),
                            onPressed: () =>
                                setState(() => _visible = !_visible),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppTheme.gold, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Login button ──
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () => _submit(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.gold,
                            foregroundColor: Colors.black,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5, color: Colors.black))
                              : const Text('Admin Login',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _submit(BuildContext ctx) {
    ctx
        .read<LoginBloc>()
        .add(LoginSubmitted(_userCtrl.text.trim(), _passCtrl.text));
  }
}
