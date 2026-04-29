import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trading_app/features/account/ui/ibkr_config_screen.dart';
import '../../../app_theme.dart';
import '../../../models/models.dart';
import '../../../services/api_service.dart';
import '../bloc/admin_bloc.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminBloc()..add(const AdminUsersLoaded()),
      child: BlocConsumer<AdminBloc, AdminState>(
        listener: (ctx, state) {
          if (state is AdminFailure) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
              content: Text('❌ ${state.message}'),
              backgroundColor: AppTheme.loss,
              behavior: SnackBarBehavior.floating,
            ));
          }
        },
        builder: (ctx, state) {
          if (state is AdminLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary));
          }

          if (state is AdminSuccess) {
            return Column(children: [
              const _ConnectionsBanner(),
              const SizedBox(height: 4),
              if (state.users.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text('No users found',
                        style: TextStyle(color: AppTheme.text2)),
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async =>
                        ctx.read<AdminBloc>().add(const AdminUsersLoaded()),
                    color: AppTheme.primary,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: state.users.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _UserCard(user: state.users[i]),
                    ),
                  ),
                ),
            ]);
          }

          if (state is AdminFailure) {
            return Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppTheme.loss, size: 48),
                    const SizedBox(height: 12),
                    Text(state.message,
                        style: const TextStyle(color: AppTheme.text2)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          ctx.read<AdminBloc>().add(const AdminUsersLoaded()),
                      child: const Text('Retry'),
                    ),
                  ]),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _ConnectionsBanner extends StatefulWidget {
  const _ConnectionsBanner();
  @override
  State<_ConnectionsBanner> createState() => _ConnectionsBannerState();
}

class _ConnectionsBannerState extends State<_ConnectionsBanner> {
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final c = await ApiService.instance.getActiveConnectionCount();
      if (mounted) setState(() => _count = c);
    } catch (_) {/* silent */}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
        Text('Active IBKR connections: $_count',
            style: const TextStyle(
                color: AppTheme.text1, fontWeight: FontWeight.bold)),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.refresh, size: 18, color: AppTheme.text2),
          onPressed: _load,
        ),
      ]),
    );
  }
}

class _UserCard extends StatelessWidget {
  final AppUser user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final isActive = user.active;
    final isAdmin = user.role == 'ADMIN';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: (isAdmin ? AppTheme.gold : AppTheme.primary)
                .withValues(alpha: 0.15),
            child: Icon(isAdmin ? Icons.shield : Icons.person,
                color: isAdmin ? AppTheme.gold : AppTheme.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user.username,
                  style: const TextStyle(
                      color: AppTheme.text1,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              Text('${user.role}  •  id ${user.id}',
                  style: const TextStyle(color: AppTheme.text2, fontSize: 11)),
            ]),
          ),
          _badge(isActive ? 'ACTIVE' : 'INACTIVE',
              isActive ? AppTheme.profit : AppTheme.loss),
        ]),
        const SizedBox(height: 12),

        // IBKR config status
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (user.isIbkrConfigured ? AppTheme.profit : AppTheme.loss)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            Icon(
                user.isIbkrConfigured
                    ? Icons.check_circle
                    : Icons.error_outline,
                size: 16,
                color: user.isIbkrConfigured ? AppTheme.profit : AppTheme.loss),
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
                child: Text(user.ibkrPaperTrading ? 'PAPER' : 'LIVE',
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 9,
                        fontWeight: FontWeight.bold)),
              ),
          ]),
        ),
        const SizedBox(height: 10),

        Row(children: [
          Expanded(
            child: _ActionBtn(
              icon: isActive ? Icons.pause : Icons.play_arrow,
              label: isActive ? 'Deactivate' : 'Activate',
              color: isActive ? AppTheme.loss : AppTheme.profit,
              onTap: () => _toggle(context, isActive),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ActionBtn(
              icon: Icons.settings_ethernet,
              label: 'IBKR',
              color: AppTheme.primary,
              onTap: () => _configure(context),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ActionBtn(
              icon: isAdmin ? Icons.person : Icons.shield,
              label: isAdmin ? '→USER' : '→ADMIN',
              color: isAdmin ? AppTheme.text2 : AppTheme.gold,
              onTap: () => _changeRole(context, isAdmin),
            ),
          ),
          const SizedBox(width: 8),
          if (!isAdmin)
            _IconBtn(
                icon: Icons.delete,
                color: AppTheme.loss,
                onTap: () => _delete(context)),
        ]),
      ]),
    );
  }

  Widget _badge(String t, Color c) => Container(
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

  void _toggle(BuildContext ctx, bool active) {
    ctx.read<AdminBloc>().add(
        active ? AdminUserDeactivated(user.id) : AdminUserActivated(user.id));
  }

  void _changeRole(BuildContext ctx, bool isAdmin) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: Text('Change ${user.username} to ${isAdmin ? 'USER' : 'ADMIN'}?',
            style: const TextStyle(color: AppTheme.text1, fontSize: 15)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctx
                  .read<AdminBloc>()
                  .add(AdminRoleChanged(user.id, isAdmin ? 'USER' : 'ADMIN'));
            },
            child: const Text('Confirm',
                style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  Future<void> _configure(BuildContext ctx) async {
    final result = await Navigator.push<bool>(
      ctx,
      MaterialPageRoute(builder: (_) => IbkrConfigScreen(user: user)),
    );
    if (result == true && ctx.mounted) {
      ctx.read<AdminBloc>().add(const AdminUsersLoaded());
    }
  }

  void _delete(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        title:
            const Text('Delete User?', style: TextStyle(color: AppTheme.text1)),
        content: Text(
            'Permanently delete "${user.username}"? This cannot be undone.',
            style: const TextStyle(color: AppTheme.text2)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctx.read<AdminBloc>().add(AdminUserDeleted(user.id));
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.loss)),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}
