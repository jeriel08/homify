import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/core/utils/toast_helper.dart';
import 'package:homify/features/auth/presentation/providers/auth_providers.dart';
import 'package:lottie/lottie.dart';

class PendingEmailVerificationPage extends ConsumerStatefulWidget {
  const PendingEmailVerificationPage({super.key});

  @override
  ConsumerState<PendingEmailVerificationPage> createState() =>
      _PendingEmailVerificationPageState();
}

class _PendingEmailVerificationPageState
    extends ConsumerState<PendingEmailVerificationPage> {
  bool _isChecking = false;
  bool _isResending = false;
  int _resendCooldown = 0;
  // ignore: unused_field
  // Timer? _timer; // We'll use Future.delayed for simplicity or a Timer if needed for countdown

  @override
  void dispose() {
    // _timer?.cancel();
    super.dispose();
  }

  Future<void> _resendEmail() async {
    setState(() => _isResending = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        if (mounted) {
          ToastHelper.success(context, 'Verification email sent!');
        }
        // Start Cooldown
        setState(() {
          _resendCooldown = 60;
          _isResending = false;
        });
        _startCooldown();
      }
    } catch (e) {
      debugPrint('Error resending email: $e');
      if (mounted) {
        ToastHelper.error(context, 'Error: $e');
      }
      setState(() => _isResending = false);
    }
  }

  void _startCooldown() async {
    while (_resendCooldown > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() {
        _resendCooldown--;
      });
    }
  }

  Future<void> _checkVerification() async {
    setState(() => _isChecking = true);
    debugPrint('--- CHECKING EMAIL VERIFICATION ---');

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('Error: No user found.');
        return;
      }

      // 1. Force Firebase to fetch the latest data from the server
      await user.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;

      debugPrint('Current Email: ${refreshedUser?.email}');
      debugPrint('Is Verified: ${refreshedUser?.emailVerified}');

      if (refreshedUser?.emailVerified == true) {
        debugPrint('SUCCESS: Email is verified. Refreshing app state...');

        await FirebaseFirestore.instance
            .collection('users')
            .doc(refreshedUser!.uid)
            .update({'email_verified': true});

        debugPrint('SYNC COMPLETE. Invalidating providers...');

        // 2. FORCE REFRESH (Crucial Step)
        // This forces the app to re-fetch the Firestore data immediately
        ref.invalidate(currentUserProvider);
        ref.invalidate(authStateProvider);
      } else {
        debugPrint('WAITING: Email still not verified.');
        if (mounted) {
          ToastHelper.warning(
            context,
            'Email not verified yet. Please check your inbox.',
          );
        }
      }
    } catch (e) {
      debugPrint('Error checking verification: $e');
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _handleLogout() async {
    debugPrint('--- LOGGING OUT ---');
    try {
      // Await the logout action
      await ref.read(authRepositoryProvider).logout();
      debugPrint('Logout successful. Router should trigger redirect.');
      // Optional: Force a refresh if the router doesn't pick it up immediately
      ref.invalidate(authStateProvider);
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      debugPrint('Logout failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/EmailAnimation.json',
              repeat: true,
              height: 250,
              width: 250,
            ),
            Text(
              'Verify your Email',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF32190D),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'We sent a link to ${FirebaseAuth.instance.currentUser?.email ?? 'your email'}.\nClick the link in that email, then tap the button below.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Check Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isChecking ? null : _checkVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF32190D),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(44),
                ),
                child: _isChecking
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Color(0xFFF9E5C5),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'I have verified my email',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // Resend Email Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _resendCooldown > 0 ? null : _resendEmail,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF32190D),
                  side: const BorderSide(color: Color(0xFF32190D)),
                  minimumSize: const Size.fromHeight(44),
                ),
                child: _isResending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF32190D),
                        ),
                      )
                    : Text(
                        _resendCooldown > 0
                            ? 'Resend in ${_resendCooldown}s'
                            : 'Resend Email',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _handleLogout,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF32190D),
                  minimumSize: const Size.fromHeight(44),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
