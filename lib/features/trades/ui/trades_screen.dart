import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../app_theme.dart';
import '../../../models/models.dart';
import '../../../services/auth_service.dart';
import '../bloc/trades_bloc.dart';
import '../../login/ui/login_screen.dart';

class TradesScreen extends StatelessWidget {
  const TradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TradesBloc()..add(const TradesLoaded()),
      child: BlocConsumer<TradesBloc, TradesState>(
        listener: (ctx, state) {
          if (state is TradesFailure && state.unauthorized) {
            _logout(ctx);
          }
        },
        builder: (ctx, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Trade History'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () =>
                      ctx.read<TradesBloc>().add(const TradesLoaded()),
                ),
              ],
            ),
            body: switch (state) {
              TradesLoading() => const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary)),
              TradesSuccess() => state.orders.isEmpty
                  ? _emptyState()
                  : RefreshIndicator(
                      onRefresh: () async =>
                          ctx.read<TradesBloc>().add(const TradesLoaded()),
                      color: AppTheme.primary,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.orders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (c, i) => _card(state.orders[i], c),
                      ),
                    ),
              TradesFailure() => _errorState(ctx, state.message),
              _ => const SizedBox(),
            },
          );
        },
      ),
    );
  }

  Widget _card(TradeOrder o, BuildContext ctx) {
    final sc = _statusColor(o.status);
    final dateStr = o.createdAt != null
        ? DateFormat('dd MMM yyyy  HH:mm').format(o.createdAt!)
        : '—';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            // BUY badge - IBKR bracket orders دائماً BUY
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.profit.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('BUY',
                  style: TextStyle(
                      color: AppTheme.profit,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
            Text(o.symbol,
                style: const TextStyle(
                    color: AppTheme.text1,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ]),
          _badge(o.status ?? 'unknown', sc),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _info('Qty', o.qty?.toStringAsFixed(0) ?? '—'),
          _info(
              'Entry',
              o.entryPrice != null
                  ? '\$${o.entryPrice!.toStringAsFixed(2)}'
                  : '—'),
          _info(
              'Take Profit',
              o.takeProfit != null
                  ? '\$${o.takeProfit!.toStringAsFixed(2)}'
                  : '—'),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          _info('Stop Loss',
              o.stopLoss != null ? '\$${o.stopLoss!.toStringAsFixed(2)}' : '—'),
          _info(
              'Stop Price',
              o.stopPrice != null
                  ? '\$${o.stopPrice!.toStringAsFixed(2)}'
                  : '—'),
          _info(
              'Limit Price',
              o.limitPrice != null
                  ? '\$${o.limitPrice!.toStringAsFixed(2)}'
                  : '—'),
        ]),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            const Icon(Icons.access_time, color: AppTheme.text2, size: 12),
            const SizedBox(width: 4),
            Text(dateStr,
                style: const TextStyle(color: AppTheme.text2, fontSize: 11)),
          ]),
          if (o.isCancellable && o.ibkrOrderId != null)
            GestureDetector(
              onTap: () => _confirmCancel(ctx, o),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.loss.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: AppTheme.loss.withValues(alpha: 0.4)),
                ),
                child: const Text('Cancel',
                    style: TextStyle(
                        color: AppTheme.loss,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ),
        ]),
      ]),
    );
  }

  void _confirmCancel(BuildContext ctx, TradeOrder o) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title:
            const Text('Cancel Order', style: TextStyle(color: AppTheme.text1)),
        content: Text('Cancel ${o.symbol} order?',
            style: const TextStyle(color: AppTheme.text2)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No', style: TextStyle(color: AppTheme.text2)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctx
                  .read<TradesBloc>()
                  .add(TradesCancelRequested(o.ibkrOrderId!)); // ← ibkrOrderId
            },
            child: const Text('Yes, Cancel',
                style: TextStyle(color: AppTheme.loss)),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String? s) {
    switch (s?.toLowerCase()) {
      case 'filled':
        return AppTheme.profit;
      case 'cancelled':
      case 'canceled':
      case 'rejected':
        return AppTheme.loss;
      case 'submitted':
      case 'presubmitted':
        return AppTheme.gold;
      default:
        return AppTheme.text2;
    }
  }

  Widget _badge(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(label.toUpperCase(),
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      );

  Widget _info(String label, String value) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(color: AppTheme.text2, fontSize: 10)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.text1,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ]),
      );

  Widget _emptyState() => const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.receipt_long, color: AppTheme.text2, size: 48),
          SizedBox(height: 12),
          Text('No orders yet', style: TextStyle(color: AppTheme.text2)),
        ]),
      );

  Widget _errorState(BuildContext ctx, String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.wifi_off, color: AppTheme.loss, size: 48),
            const SizedBox(height: 12),
            Text(msg,
                style: const TextStyle(color: AppTheme.text2),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ctx.read<TradesBloc>().add(const TradesLoaded()),
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
