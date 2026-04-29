import 'package:flutter/material.dart';
import '../../../app_theme.dart';
import '../../../models/models.dart';
import '../../../services/api_service.dart';
import 'ibkr_config_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  Future<List<AppUser>>? _usersFuture;
  int _activeConnections = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _usersFuture = ApiService.instance.getUsers();
    });
    ApiService.instance.getActiveConnectionCount().then((c) {
      if (mounted) setState(() => _activeConnections = c);
    }).catchError((_) {});
  }

  Future<void> _toggleActive(AppUser user) async {
    try {
      if (user.active) {
        await ApiService.instance.deactivateUser(user.id);
      } else {
        await ApiService.instance.activateUser(user.id);
      }
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('❌ ${e.toString().replaceAll('Exception: ', '')}'),
        backgroundColor: AppTheme.loss,
      ));
    }
  }

  Future<void> _delete(AppUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        title:
            const Text('Delete User?', style: TextStyle(color: AppTheme.text1)),
        content: Text(
          'Permanently delete "${user.username}"? This cannot be undone.',
          style: const TextStyle(color: AppTheme.text2),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text('Delete', style: TextStyle(color: AppTheme.loss))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.instance.deleteUser(user.id);
        _load();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('❌ ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: AppTheme.loss,
        ));
      }
    }
  }

  Future<void> _configureIbkr(AppUser user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => IbkrConfigScreen(user: user)),
    );
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: Column(children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.profit.withValues(alpha: 0.3)),
          ),
          child: Row(children: [
            const Icon(Icons.cable, color: AppTheme.profit),
            const SizedBox(width: 12),
            Text('Active IBKR connections: $_activeConnections',
                style: const TextStyle(
                    color: AppTheme.text1, fontWeight: FontWeight.bold)),
          ]),
        ),
        Expanded(
          child: FutureBuilder<List<AppUser>>(
            future: _usersFuture,
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: AppTheme.gold));
              }
              if (snap.hasError) {
                return _errorState(snap.error.toString());
              }
              final users = snap.data ?? [];
              if (users.isEmpty) {
                return const Center(
                  child: Text('No users yet',
                      style: TextStyle(color: AppTheme.text2)),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => _load(),
                color: AppTheme.gold,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _userCard(users[i]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _userCard(AppUser user) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (user.role == 'ADMIN' ? AppTheme.gold : AppTheme.primary)
                  .withValues(alpha: 0.15),
            ),
            child: Icon(
              user.role == 'ADMIN' ? Icons.shield : Icons.person,
              color: user.role == 'ADMIN' ? AppTheme.gold : AppTheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user.username,
                  style: const TextStyle(
                      color: AppTheme.text1,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              Text(user.role,
                  style: const TextStyle(color: AppTheme.text2, fontSize: 11)),
            ]),
          ),
          _statusBadge(user.active ? 'ACTIVE' : 'INACTIVE',
              user.active ? AppTheme.profit : AppTheme.loss),
        ]),
        const SizedBox(height: 12),

        // IBKR config status
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: user.isIbkrConfigured
                ? AppTheme.profit.withValues(alpha: 0.1)
                : AppTheme.loss.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            Icon(
              user.isIbkrConfigured ? Icons.check_circle : Icons.error_outline,
              size: 16,
              color: user.isIbkrConfigured ? AppTheme.profit : AppTheme.loss,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                user.isIbkrConfigured
                    ? '${user.ibkrHost}:${user.ibkrPort} → ${user.ibkrAccountId}'
                    : 'IBKR not configured',
                style: const TextStyle(color: AppTheme.text1, fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (user.isIbkrConfigured)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      user.ibkrPaperTrading ? AppTheme.profit : AppTheme.loss,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  user.ibkrPaperTrading ? 'PAPER' : 'LIVE',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 9,
                      fontWeight: FontWeight.bold),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 12),

        // Action buttons
        Row(children: [
          Expanded(
            child: _actionBtn(
              user.active ? Icons.pause : Icons.play_arrow,
              user.active ? 'Deactivate' : 'Activate',
              user.active ? AppTheme.loss : AppTheme.profit,
              () => _toggleActive(user),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _actionBtn(
              Icons.settings_ethernet,
              'IBKR',
              AppTheme.primary,
              () => _configureIbkr(user),
            ),
          ),
          const SizedBox(width: 8),
          if (user.role != 'ADMIN')
            _iconBtn(Icons.delete, AppTheme.loss, () => _delete(user)),
        ]),
      ]),
    );
  }

  Widget _statusBadge(String t, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.withValues(alpha: 0.5)),
        ),
        child: Text(t,
            style:
                TextStyle(color: c, fontSize: 9, fontWeight: FontWeight.bold)),
      );

  Widget _actionBtn(IconData i, String t, Color c, VoidCallback onTap) =>
      Material(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(i, size: 14, color: c),
              const SizedBox(width: 4),
              Text(t,
                  style: TextStyle(
                      color: c, fontSize: 11, fontWeight: FontWeight.bold)),
            ]),
          ),
        ),
      );

  Widget _iconBtn(IconData i, Color c, VoidCallback onTap) => Material(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(i, size: 16, color: c),
          ),
        ),
      );

  Widget _errorState(String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.error_outline, color: AppTheme.loss, size: 48),
            const SizedBox(height: 12),
            Text(msg.replaceAll('Exception: ', ''),
                style: const TextStyle(color: AppTheme.text2),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ]),
        ),
      );
}
