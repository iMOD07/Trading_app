import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app_theme.dart';
import '../../../models/models.dart';
import '../../../services/auth_service.dart';
import '../bloc/settings_bloc.dart';
import '../../login/ui/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _amountCtrl = TextEditingController();
  final _rangeCtrl = TextEditingController();
  final _profitCtrl = TextEditingController();

  int tradeAmount = 0;
  double rangeValue = 0;
  int profitPercent = 0;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _rangeCtrl.dispose();
    _profitCtrl.dispose();
    super.dispose();
  }

  void _populate(AppSettings s) {
    _amountCtrl.text = s.tradeAmount.toString();
    _rangeCtrl.text = s.rangeValue.toString();
    _profitCtrl.text = s.profitPercent.toString();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsBloc()..add(const SettingsLoaded()),
      child: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (ctx, state) {
          if (state is SettingsDataLoaded) _populate(state.settings);
          if (state is SettingsSaveSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
              content: Text('✅ Settings saved!'),
              backgroundColor: AppTheme.profit,
              behavior: SnackBarBehavior.floating,
            ));
          }
          if (state is SettingsFailure && state.message == 'UNAUTHORIZED') {
            _logout(ctx);
          }
        },
        builder: (ctx, state) {
          final isLoading = state is SettingsLoading;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Settings'),
            ),
            body: state is SettingsLoading && _amountCtrl.text.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary))
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppTheme.primary.withValues(alpha: 0.25)),
                        ),
                        child: const Row(children: [
                          Icon(Icons.tune, color: AppTheme.primary, size: 26),
                          SizedBox(width: 12),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Trading Defaults',
                                    style: TextStyle(
                                        color: AppTheme.text1,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                Text('Saved to your account on the server',
                                    style: TextStyle(
                                        color: AppTheme.text2, fontSize: 12)),
                              ]),
                        ]),
                      ),
                      const SizedBox(height: 15),
                      Text("Trading amount: ${_amountCtrl.text} USD",
                          style: const TextStyle(
                              color: AppTheme.text2,
                              fontSize: 13,
                              fontWeight: FontWeight.w900)),
                      Text("Incorrection percentage: ${_rangeCtrl.text}",
                          style: const TextStyle(
                              color: AppTheme.text2,
                              fontSize: 13,
                              fontWeight: FontWeight.w900)),
                      Text("Profit percentage: ${_profitCtrl.text}",
                          style: const TextStyle(
                              color: AppTheme.text2,
                              fontSize: 13,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 20),

                      _label('Trade Amount \$'),
                      _field(_amountCtrl, '500',
                          helperText: 'Amount per trade in USD'),
                      const SizedBox(height: 18),

                      _label('Range Value'),
                      _field(_rangeCtrl, '0.01',
                          helperText:
                              'Difference between entry and limit price'),
                      const SizedBox(height: 18),

                      _label('Profit %'),
                      _field(_profitCtrl, '6',
                          helperText: 'Target profit percentage'),
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () => _save(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: state is SettingsSaveSuccess
                                ? AppTheme.profit.withValues(alpha: 0.8)
                                : AppTheme.primary,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5, color: Colors.black))
                              : const Text('Save Settings'),
                        ),
                      ),

                      if (state is SettingsFailure) ...[
                        const SizedBox(height: 12),
                        Text(state.message,
                            style: const TextStyle(
                                color: AppTheme.loss, fontSize: 13),
                            textAlign: TextAlign.center),
                      ],

                    ],
                  ),
          );
        },
      ),
    );
  }

  void _save(BuildContext ctx) {
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    final range = double.tryParse(_rangeCtrl.text) ?? 0;
    final profit = double.tryParse(_profitCtrl.text) ?? 0;
    ctx.read<SettingsBloc>().add(SettingsSaved(
          AppSettings(
              tradeAmount: amount, rangeValue: range, profitPercent: profit),
        ));
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

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t,
            style: const TextStyle(
                color: AppTheme.text2,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      );

  Widget _field(TextEditingController ctrl, String hint, {String? helperText}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: AppTheme.text1),
      decoration: InputDecoration(
          hintText: hint,
          helperText: helperText,
          helperStyle: const TextStyle(color: AppTheme.text2, fontSize: 11)),
    );
  }
}
