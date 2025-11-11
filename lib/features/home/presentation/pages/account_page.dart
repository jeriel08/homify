// lib/features/home/presentation/pages/account/account_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/features/auth/presentation/controllers/account_controller.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<void>>(logoutControllerProvider, (previous, next) {
      if (next.hasError) {
        // Show an error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (next.hasValue) {
        // Success! Navigate the user out
        // Use context.go() to clear the navigation stack and go to login
        context.go('/login');
      }
    });

    final logoutState = ref.watch(logoutControllerProvider);
    final isLoading = logoutState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Account & Settings',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF32190D),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF9E5C5),
        foregroundColor: const Color(0xFF32190D),
        elevation: 6,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.2),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ───── PROFILE HEADER ─────
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 36,
                backgroundColor: Colors.grey.shade300,
                child: const Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(width: 16),

              // Name + View profile
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "John Benedic Dutaro",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile page – coming soon'),
                          ),
                        );
                      },
                      child: const Text('View profile'),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 32),

          // ───── ADMIN SECTION (only for admin) ─────
          ListTile(
            leading: const Icon(Icons.approval),
            title: const Text('Review Pending Properties'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/pending-properties'),
          ),
          const Divider(),

          // ───── LOGOUT ─────
          // ───── LOGOUT ─────
          ListTile(
            enabled: !isLoading, // Disable tile when loading
            leading: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.red,
                    ),
                  )
                : const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              // 1. Show confirmation
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => context.pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => context.pop(true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirm != true) return;

              ref.read(logoutControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }
}
