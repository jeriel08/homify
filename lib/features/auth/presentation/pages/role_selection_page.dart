import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/core/entities/user_entity.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';

class RoleSelectionPage extends ConsumerStatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  ConsumerState<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends ConsumerState<RoleSelectionPage> {
  bool _isLoading = false;

  Future<void> _selectRole(AccountType type) async {
    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      // 1. Update Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'account_type': type.name,
      });

      // 2. Navigate to the appropriate onboarding
      if (mounted) {
        if (type == AccountType.tenant) {
          context.go('/tenant-onboarding');
        } else {
          context.go('/owner-onboarding'); // Or owner success/dashboard
        }
      }
    } catch (e) {
      if (mounted) {
        DelightToastBar(
          autoDismiss: true,
          snackbarDuration: const Duration(seconds: 3),
          position: DelightSnackbarPosition.top,
          builder: (context) => ToastCard(
            leading: const Icon(
              LucideIcons.triangleAlert,
              size: 28,
              color: Colors.red,
            ),
            title: Text(
              'Error updating role: $e',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF32190D),
              ),
            ),
            color: Colors.white,
          ),
        ).show(context);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Gap(40),
              const Text(
                'Welcome to Homify!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const Gap(8),
              const Text(
                'To get started, please tell us how you plan to use the app.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const Gap(60),

              // Tenant Button
              _RoleCard(
                icon: LucideIcons.search,
                title: 'I am a Tenant',
                subtitle: 'I am looking for a place to stay.',
                isLoading: _isLoading,
                onTap: () => _selectRole(AccountType.tenant),
              ),

              const Gap(20),

              // Owner Button
              _RoleCard(
                icon: LucideIcons.house,
                title: 'I am an Owner',
                subtitle: 'I want to list my property.',
                isLoading: _isLoading,
                onTap: () => _selectRole(AccountType.owner),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLoading;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE05725).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFFE05725), size: 24),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
