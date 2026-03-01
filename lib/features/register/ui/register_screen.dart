import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app_theme.dart';
import '../bloc/register_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _userCtrl  = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _keyCtrl   = TextEditingController();
  final _secCtrl   = TextEditingController();
  bool _passVisible = false;
  bool _secVisible  = false;

  @override
  void dispose() {
    _userCtrl.dispose(); _passCtrl.dispose();
    _keyCtrl.dispose();  _secCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterBloc(),
      child: BlocConsumer<RegisterBloc, RegisterState>(
        listener: (ctx, state) {
          if (state is RegisterSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
              content: Text('✅ Account created! Please login.'),
              backgroundColor: AppTheme.profit,
            ));
            Navigator.pop(ctx);
          } else if (state is RegisterFailure) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
              content: Text('❌ ${state.message}'),
              backgroundColor: AppTheme.loss,
            ));
          }
        },
        builder: (ctx, state) {
          final isLoading = state is RegisterLoading;
          return Scaffold(
            appBar: AppBar(title: const Text('Create Account')),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
                    ),
                    child: const Row(children: [
                      Icon(Icons.person_add, color: AppTheme.primary, size: 26),
                      SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('New Account', style: TextStyle(color: AppTheme.text1, fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('Enter your Alpaca API credentials', style: TextStyle(color: AppTheme.text2, fontSize: 12)),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 28),

                  _label('Username'),
                  _textField(_userCtrl, 'mohammed', required: true),
                  const SizedBox(height: 14),

                  _label('Password'),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: !_passVisible,
                    style: const TextStyle(color: AppTheme.text1),
                    decoration: InputDecoration(
                      hintText: '••••••',
                      suffixIcon: IconButton(
                        icon: Icon(_passVisible ? Icons.visibility_off : Icons.visibility, color: AppTheme.text2, size: 20),
                        onPressed: () => setState(() => _passVisible = !_passVisible),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
                  ),
                  const SizedBox(height: 24),

                  const Divider(color: AppTheme.border),
                  const SizedBox(height: 16),
                  const Text('Alpaca API', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 14),

                  _label('API Key'),
                  _textField(_keyCtrl, 'PK...', required: true),
                  const SizedBox(height: 14),

                  _label('Secret Key'),
                  TextFormField(
                    controller: _secCtrl,
                    obscureText: !_secVisible,
                    style: const TextStyle(color: AppTheme.text1),
                    decoration: InputDecoration(
                      hintText: '••••••',
                      suffixIcon: IconButton(
                        icon: Icon(_secVisible ? Icons.visibility_off : Icons.visibility, color: AppTheme.text2, size: 20),
                        onPressed: () => setState(() => _secVisible = !_secVisible),
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => _submit(ctx),
                      child: isLoading
                          ? const SizedBox(height: 20, width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black))
                          : const Text('Create Account'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _submit(BuildContext ctx) {
    if (!_formKey.currentState!.validate()) return;
    ctx.read<RegisterBloc>().add(RegisterSubmitted(
      username: _userCtrl.text.trim(),
      password: _passCtrl.text,
      apiKey:   _keyCtrl.text.trim(),
      apiSecret: _secCtrl.text.trim(),
    ));
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(t, style: const TextStyle(color: AppTheme.text2, fontSize: 12, fontWeight: FontWeight.w600)),
  );

  Widget _textField(TextEditingController ctrl, String hint, {bool required = false}) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: AppTheme.text1),
      decoration: InputDecoration(hintText: hint),
      validator: (v) => (required && (v == null || v.isEmpty)) ? 'Required' : null,
    );
  }
}
