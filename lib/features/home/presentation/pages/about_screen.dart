import 'package:flutter/material.dart';
import 'package:homify/core/theme/app_colors.dart';
import 'package:gap/gap.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          24,
          24,
          24,
          100,
        ), // Bottom padding for nav bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'About Homify',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(20),

            // Main Content Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Logo Asset
                  Image.asset(
                    'assets/images/Homify_Icon_Transparent.png',
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const Gap(12),

                  Text(
                    'Welcome to Homify',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 24,
                    ),
                  ),
                  const Gap(16),

                  Text(
                    'Homify connects tenants with their dream homes and helps owners manage their properties with ease.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[700],
                      height: 1.6,
                    ),
                  ),
                  const Gap(16),
                  Text(
                    'Whether you are looking for a place to stay or managing your real estate portfolio, we have got you covered.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[700],
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
