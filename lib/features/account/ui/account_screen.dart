import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../app_theme.dart';
import '../../../services/auth_service.dart';
import '../bloc/account_bloc.dart';
import '../../login/ui/login_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  String _fmt(double v) =>
      NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(v);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AccountBloc()..add(const AccountLoaded()),
      child: BlocConsumer<AccountBloc, AccountState>(
        listener: (ctx, state) {
          if (state is AccountFailure && state.unauthorized) _logout(ctx);
        },
        builder: (ctx, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Account'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () =>
                      ctx.read<AccountBloc>().add(const AccountLoaded()),
                ),
              ],
            ),
            body: switch (state) {
              AccountLoading() => const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary)),
              AccountSuccess() => RefreshIndicator(
                  onRefresh: () async =>
                      ctx.read<AccountBloc>().add(const AccountLoaded()),
                  color: AppTheme.primary,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _portfolioCard(state.account),
                      const SizedBox(height: 16),
                      _statsGrid(state.account),
                    ],
                  ),
                ),
              AccountFailure() => _errorState(ctx, state.message),
              _ => const SizedBox(),
            },
          );
        },
      ),
    );
  }

  Widget _portfolioCard(account) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primary.withValues(alpha: 0.2), AppTheme.card],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Portfolio Value',
                style: TextStyle(color: AppTheme.text2, fontSize: 13)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.profit.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(account.status.toUpperCase(),
                  style: const TextStyle(
                      color: AppTheme.profit,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(_fmt(account.portfolioValue),
              style: const TextStyle(
                  color: AppTheme.text1,
                  fontSize: 32,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Equity: ${_fmt(account.equity)}',
              style: const TextStyle(color: AppTheme.text2, fontSize: 13)),
        ]),
      );

  Widget _statsGrid(account) {
    final items = [
      ('💵 Cash', _fmt(account.cash), AppTheme.text1),
      ('⚡ Buying Power', _fmt(account.buyingPower), AppTheme.profit),
      (
        '📊 Day Trades',
        account.daytradeCount.toInt().toString(),
        AppTheme.gold
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: items
          .map((item) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item.$1,
                        style: const TextStyle(
                            color: AppTheme.text2, fontSize: 12)),
                    const SizedBox(height: 6),
                    Text(item.$2,
                        style: TextStyle(
                            color: item.$3,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _errorState(BuildContext ctx, String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.wifi_off, color: AppTheme.loss, size: 56),
            const SizedBox(height: 16),
            Text(msg,
                style: const TextStyle(color: AppTheme.text2, fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () =>
                  ctx.read<AccountBloc>().add(const AccountLoaded()),
              child: const Text('Retry'),
            ),
          ]),
        ),
      );

  void _logout(BuildContext ctx) async {
    await AuthService.clear();
    if (ctx.mounted) {
      Navigator.pushAndRemoveUntil(ctx,
          MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
    }
  }
}
