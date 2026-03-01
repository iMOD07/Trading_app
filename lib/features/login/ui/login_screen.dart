import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app_theme.dart';
import '../bloc/login_bloc.dart';
import '../../main_navigation.dart';
import '../../register/ui/register_screen.dart';
import '../../admin/ui/admin_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
                ctx, MaterialPageRoute(builder: (_) => const MainNavigation()));
          }
        },
        builder: (ctx, state) {
          final isLoading = state is LoginLoading;
          final error = state is LoginFailure ? state.message : null;

          return Scaffold(
            backgroundColor: AppTheme.background,
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          border: Border.all(color: AppTheme.primary, width: 2),
                        ),
                        child: const Icon(Icons.candlestick_chart,
                            color: AppTheme.primary, size: 44),
                      ),
                      const SizedBox(height: 28),
                      const Text('Alpaca Trading Bot',
                          style: TextStyle(
                              color: AppTheme.text1,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      const Text('Powered by Spring Boot + Alpaca',
                          style:
                              TextStyle(color: AppTheme.text2, fontSize: 13)),
                      const SizedBox(height: 48),

                      // Username
                      TextField(
                        controller: _userCtrl,
                        style: const TextStyle(color: AppTheme.text1),
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person_outline,
                              color: AppTheme.text2, size: 20),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Password
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
                          errorText: error,
                          errorStyle: const TextStyle(color: AppTheme.loss),
                        ),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () => _submit(ctx),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5, color: Colors.black))
                              : const Text('Login'),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Register link
                      TextButton(
                        onPressed: () => Navigator.push(
                            ctx,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen())),
                        child: const Text("Don't have an account? Register",
                            style: TextStyle(
                                color: AppTheme.primary, fontSize: 13)),
                      ),

                      const SizedBox(height: 32),

                      // Admin Login
                      GestureDetector(
                        onTap: () => Navigator.push(
                            ctx,
                            MaterialPageRoute(
                                builder: (_) => const AdminLoginScreen())),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: AppTheme.gold.withValues(alpha: 0.4)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.admin_panel_settings,
                                  color: AppTheme.gold, size: 14),
                              SizedBox(width: 6),
                              Text('Admin',
                                  style: TextStyle(
                                      color: AppTheme.gold,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
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
