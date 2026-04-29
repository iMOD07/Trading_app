import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app_theme.dart';
import '../../../models/models.dart';
import '../../../services/api_service.dart';

/// Admin screen to configure IBKR connection for a specific user.
/// Each user has a separate VPS running IB Gateway.
class IbkrConfigScreen extends StatefulWidget {
  final AppUser user;
  const IbkrConfigScreen({super.key, required this.user});

  @override
  State<IbkrConfigScreen> createState() => _IbkrConfigScreenState();
}

class _IbkrConfigScreenState extends State<IbkrConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _hostCtrl;
  late TextEditingController _portCtrl;
  late TextEditingController _clientIdCtrl;
  late TextEditingController _accountCtrl;
  bool _paperTrading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _hostCtrl = TextEditingController(text: widget.user.ibkrHost ?? '');
    _portCtrl =
        TextEditingController(text: (widget.user.ibkrPort ?? 4002).toString());
    _clientIdCtrl =
        TextEditingController(text: (widget.user.ibkrClientId ?? 1).toString());
    _accountCtrl = TextEditingController(text: widget.user.ibkrAccountId ?? '');
    _paperTrading = widget.user.ibkrPaperTrading;
  }

  @override
  void dispose() {
    _hostCtrl.dispose();
    _portCtrl.dispose();
    _clientIdCtrl.dispose();
    _accountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await ApiService.instance.configureIbkr(
        widget.user.id,
        IbkrConfigRequest(
          ibkrHost: _hostCtrl.text.trim(),
          ibkrPort: int.parse(_portCtrl.text.trim()),
          ibkrClientId: int.parse(_clientIdCtrl.text.trim()),
          ibkrAccountId: _accountCtrl.text.trim(),
          ibkrPaperTrading: _paperTrading,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('✅ IBKR config saved'),
        backgroundColor: AppTheme.profit,
      ));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('❌ ${e.toString().replaceAll('Exception: ', '')}'),
        backgroundColor: AppTheme.loss,
      ));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IBKR Config: ${widget.user.username}'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _infoCard(),
            const SizedBox(height: 20),

            _label('VPS Host (IP or domain)'),
            TextFormField(
              controller: _hostCtrl,
              style: const TextStyle(color: AppTheme.text1),
              decoration: const InputDecoration(
                hintText: 'e.g. 45.32.123.45',
                prefixIcon: Icon(Icons.dns, color: AppTheme.text2),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'VPS IP required';
                return null;
              },
            ),
            const SizedBox(height: 14),

            Row(children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Port'),
                      TextFormField(
                        controller: _portCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: const TextStyle(color: AppTheme.text1),
                        decoration: const InputDecoration(
                          hintText: '4002',
                          helperText: '4002=Paper, 4001=Live',
                          helperStyle:
                              TextStyle(color: AppTheme.text2, fontSize: 11),
                        ),
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n < 1024 || n > 65535)
                            return 'Invalid port';
                          return null;
                        },
                      ),
                    ]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Client ID'),
                      TextFormField(
                        controller: _clientIdCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: const TextStyle(color: AppTheme.text1),
                        decoration: const InputDecoration(
                          hintText: '1',
                          helperText: 'Usually 1',
                          helperStyle:
                              TextStyle(color: AppTheme.text2, fontSize: 11),
                        ),
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n < 0 || n > 999) return 'Invalid';
                          return null;
                        },
                      ),
                    ]),
              ),
            ]),
            const SizedBox(height: 14),

            _label('IBKR Account ID'),
            TextFormField(
              controller: _accountCtrl,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(color: AppTheme.text1),
              decoration: const InputDecoration(
                hintText: 'U1234567 (Live) or DU1234567 (Paper)',
                prefixIcon: Icon(Icons.account_balance, color: AppTheme.text2),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Account ID required'
                  : null,
            ),
            const SizedBox(height: 20),

            // Paper / Live toggle
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _paperTrading ? AppTheme.profit : AppTheme.loss,
                  width: 1.5,
                ),
              ),
              child: Row(children: [
                Icon(
                  _paperTrading ? Icons.shield : Icons.warning,
                  color: _paperTrading ? AppTheme.profit : AppTheme.loss,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _paperTrading ? 'Paper Trading (Safe)' : 'LIVE TRADING',
                        style: TextStyle(
                          color:
                              _paperTrading ? AppTheme.profit : AppTheme.loss,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _paperTrading
                            ? 'Simulated trades, no real money'
                            : '⚠️ Real money will be used!',
                        style: const TextStyle(
                          color: AppTheme.text2,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: !_paperTrading,
                  activeColor: AppTheme.loss,
                  onChanged: (v) {
                    if (v) {
                      // Confirm switching to live
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: AppTheme.card,
                          title: const Text(
                            '⚠️ Enable Live Trading?',
                            style: TextStyle(color: AppTheme.loss),
                          ),
                          content: const Text(
                            'Real money will be used for all trades. '
                            'Make sure the user has tested in paper mode first.',
                            style: TextStyle(color: AppTheme.text2),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                setState(() => _paperTrading = false);
                              },
                              child: const Text(
                                'Enable Live',
                                style: TextStyle(color: AppTheme.loss),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      setState(() => _paperTrading = true);
                    }
                  },
                ),
              ]),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.black,
                        ),
                      )
                    : const Text('Save IBKR Config'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
        ),
        child: const Row(children: [
          Icon(Icons.info_outline, color: AppTheme.primary, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Each user runs IB Gateway on their own VPS. '
              'Enter the VPS connection details here.',
              style: TextStyle(color: AppTheme.text2, fontSize: 12),
            ),
          ),
        ]),
      );

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t,
            style: const TextStyle(
              color: AppTheme.text2,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            )),
      );
}
