import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app_theme.dart';
import '../bloc/order_bloc.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});
  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symbolCtrl = TextEditingController();
  final _entryCtrl = TextEditingController();
  final _slCtrl = TextEditingController();

  @override
  void dispose() {
    _symbolCtrl.dispose();
    _entryCtrl.dispose();
    _slCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext ctx) {
    if (!_formKey.currentState!.validate()) return;
    ctx.read<OrderBloc>().add(OrderSubmitted(
          symbol: _symbolCtrl.text.trim().toUpperCase(),
          entryPrice: double.parse(_entryCtrl.text),
          stopLoss: double.parse(_slCtrl.text),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderBloc(),
      child: BlocConsumer<OrderBloc, OrderState>(
        listener: (ctx, state) {
          if (state is OrderSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
              content: const Row(children: [
                Icon(Icons.check_circle, color: Colors.black, size: 16),
                SizedBox(width: 8),
                Text('Order sent successfully!'),
              ]),
              backgroundColor: AppTheme.profit,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ));
          } else if (state is OrderFailure) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
              content: Row(children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(state.message)),
              ]),
              backgroundColor: AppTheme.loss,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ));
          }
        },
        builder: (ctx, state) {
          final isLoading = state is OrderLoading;
          return Scaffold(
            appBar: AppBar(title: const Text('New Order')),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Header card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary.withValues(alpha: 0.15),
                          AppTheme.card
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.25)),
                    ),
                    child: const Row(children: [
                      Icon(Icons.candlestick_chart,
                          color: AppTheme.primary, size: 28),
                      SizedBox(width: 12),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('IBKR Trading Bot',
                                style: TextStyle(
                                    color: AppTheme.text1,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                            Text('tradeAmount & range from Settings ⚙️',
                                style: TextStyle(
                                    color: AppTheme.text2, fontSize: 12)),
                          ]),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  // Symbol
                  _label('Symbol'),
                  TextFormField(
                    controller: _symbolCtrl,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(color: AppTheme.text1),
                    decoration: const InputDecoration(hintText: 'e.g. AAPL'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),

                  // Entry + StopLoss
                  Row(children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          _label('Entry Price \$'),
                          TextFormField(
                            controller: _entryCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            style: const TextStyle(color: AppTheme.text1),
                            decoration: const InputDecoration(hintText: '1.50'),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (double.tryParse(v) == null) return 'Invalid';
                              return null;
                            },
                          ),
                        ])),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          _label('Stop Loss \$'),
                          TextFormField(
                            controller: _slCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            style: const TextStyle(color: AppTheme.text1),
                            decoration: const InputDecoration(hintText: '1.10'),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              final sl = double.tryParse(v);
                              if (sl == null) return 'Invalid';
                              final entry = double.tryParse(_entryCtrl.text);
                              if (entry != null && sl >= entry)
                                // ignore: curly_braces_in_flow_control_structures
                                return 'Must be less than entry price';
                              return null;
                            },
                          ),
                        ])),
                  ]),
                  const SizedBox(height: 28),

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
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.rocket_launch, size: 16),
                                SizedBox(width: 8),
                                Text('Send Order'),
                              ],
                            ),
                    ),
                  ),

                  // Result
                  if (state is OrderSuccess) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppTheme.profit.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(children: [
                            Icon(Icons.check_circle,
                                color: AppTheme.profit, size: 18),
                            SizedBox(width: 8),
                            Text('Order Response',
                                style: TextStyle(
                                    color: AppTheme.profit,
                                    fontWeight: FontWeight.bold)),
                          ]),
                          const SizedBox(height: 12),
                          ...state.result.entries
                              .where((e) => e.key != 'rawResponse')
                              .map((e) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 3),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(e.key,
                                            style: const TextStyle(
                                                color: AppTheme.text2,
                                                fontSize: 12)),
                                        Flexible(
                                            child: Text(e.value.toString(),
                                                style: const TextStyle(
                                                    color: AppTheme.text1,
                                                    fontSize: 12),
                                                textAlign: TextAlign.end)),
                                      ],
                                    ),
                                  )),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t,
            style: const TextStyle(
                color: AppTheme.text2,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      );
}
