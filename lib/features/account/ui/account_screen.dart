import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trading_app/models/models.dart';
import '../../../app_theme.dart';
import '../../../services/auth_service.dart';
import '../bloc/account_bloc.dart';
import '../../login/ui/login_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

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
              title: const Text('IBKR Connection'),
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
                      _statusCard(state.status),
                      const SizedBox(height: 16),
                      _detailsCard(state.status),
                      if (state.status.error != null) ...[
                        const SizedBox(height: 16),
                        _errorCard(state.status.error!),
                      ],
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

  Widget _statusCard(ConnectionStatus s) {
    final isOk = s.connected;
    final color = isOk ? AppTheme.profit : AppTheme.loss;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.15), AppTheme.card],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(isOk ? Icons.check_circle : Icons.cancel,
              color: color, size: 28),
          const SizedBox(width: 12),
          Text(isOk ? 'Connected' : 'Disconnected',
              style: TextStyle(
                  color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          const Spacer(),
          if (s.paperTrading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.profit.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('PAPER',
                  style: TextStyle(
                      color: AppTheme.profit,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.loss.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('LIVE',
                  style: TextStyle(
                      color: AppTheme.loss,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
        ]),
        const SizedBox(height: 8),
        Text(
          isOk
              ? 'Your IBKR Gateway is reachable and ready to trade.'
              : 'Cannot reach IB Gateway. Contact admin to verify VPS is running.',
          style: const TextStyle(color: AppTheme.text2, fontSize: 13),
        ),
      ]),
    );
  }

  Widget _detailsCard(ConnectionStatus s) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Connection Details',
            style: TextStyle(
                color: AppTheme.text1,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _row('Account ID', s.accountId ?? '—'),
        _row('Host', s.host ?? '—'),
        _row('Port', s.port?.toString() ?? '—'),
        _row('Mode', s.paperTrading ? 'Paper Trading' : 'LIVE Trading'),
      ]),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(k, style: const TextStyle(color: AppTheme.text2, fontSize: 12)),
          Text(v,
              style: const TextStyle(
                  color: AppTheme.text1,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ]),
      );

  Widget _errorCard(String err) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.loss.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.loss.withValues(alpha: 0.3)),
        ),
        child: Row(children: [
          const Icon(Icons.error_outline, color: AppTheme.loss, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(err,
                style: const TextStyle(color: AppTheme.text1, fontSize: 12)),
          ),
        ]),
      );

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
      Navigator.pushAndRemoveUntil(
        ctx,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }
}
