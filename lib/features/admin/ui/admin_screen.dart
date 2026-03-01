import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app_theme.dart';
import '../../../models/models.dart';
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
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }

          if (state is AdminSuccess) {
            if (state.users.isEmpty) {
              return const Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.people_outline, color: AppTheme.text2, size: 48),
                  SizedBox(height: 12),
                  Text('No users found', style: TextStyle(color: AppTheme.text2)),
                ]),
              );
            }
            return Column(
              children: [
                // Stats bar
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _stat('Total', state.users.length.toString(), AppTheme.text1),
                      _stat('Active',
                        state.users.where((u) => u.active).length.toString(),
                        AppTheme.profit),
                      _stat('Inactive',
                        state.users.where((u) => !u.active).length.toString(),
                        AppTheme.loss),
                      _stat('Admins',
                        state.users.where((u) => u.role == 'ADMIN').length.toString(),
                        AppTheme.gold),
                    ],
                  ),
                ),
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
              ],
            );
          }

          if (state is AdminFailure) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.error_outline, color: AppTheme.loss, size: 48),
                const SizedBox(height: 12),
                Text(state.message, style: const TextStyle(color: AppTheme.text2)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ctx.read<AdminBloc>().add(const AdminUsersLoaded()),
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

  Widget _stat(String label, String value, Color color) => Column(
    children: [
      Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: AppTheme.text2, fontSize: 11)),
    ],
  );
}

class _UserCard extends StatelessWidget {
  final AppUser user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final isActive    = user.active;
    final isAdmin     = user.role == 'ADMIN';
    final statusColor = isActive ? AppTheme.profit : AppTheme.loss;

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
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
              child: Text(
                user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user.username,
                style: const TextStyle(color: AppTheme.text1,
                  fontWeight: FontWeight.bold, fontSize: 15)),
              Text('ID: ${user.id}',
                style: const TextStyle(color: AppTheme.text2, fontSize: 11)),
            ]),
          ]),
          _badge(isActive ? 'ACTIVE' : 'INACTIVE', statusColor),
        ]),
        const SizedBox(height: 12),
        const Divider(color: AppTheme.border, height: 1),
        const SizedBox(height: 12),
        Row(children: [
          _badge(user.role, isAdmin ? AppTheme.gold : AppTheme.primary),
          const Spacer(),
          _ActionBtn(
            label: isActive ? 'Deactivate' : 'Activate',
            color: isActive ? AppTheme.loss : AppTheme.profit,
            onTap: () => _confirm(context,
              title: '${isActive ? 'Deactivate' : 'Activate'} ${user.username}?',
              onConfirm: () => context.read<AdminBloc>().add(
                isActive ? AdminUserDeactivated(user.id) : AdminUserActivated(user.id)),
            ),
          ),
          const SizedBox(width: 8),
          _ActionBtn(
            label: isAdmin ? '→ USER' : '→ ADMIN',
            color: isAdmin ? AppTheme.text2 : AppTheme.gold,
            onTap: () => _confirm(context,
              title: 'Change ${user.username} to ${isAdmin ? 'USER' : 'ADMIN'}?',
              onConfirm: () => context.read<AdminBloc>().add(
                AdminRoleChanged(user.id, isAdmin ? 'USER' : 'ADMIN')),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.4)),
    ),
    child: Text(label,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
  );

  void _confirm(BuildContext ctx, {required String title, required VoidCallback onConfirm}) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: AppTheme.card,
      title: Text(title, style: const TextStyle(color: AppTheme.text1, fontSize: 15)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        TextButton(
          onPressed: () { Navigator.pop(ctx); onConfirm(); },
          child: const Text('Confirm', style: TextStyle(color: AppTheme.primary)),
        ),
      ],
    ));
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(label,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
