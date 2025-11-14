import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr, // Or .rtl for other languages
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center the content
            children: [
              Lottie.asset(
                'assets/animations/LoadingAnimation.json',
                height: 250,
                width: 250,
              ),
              const SizedBox(height: 40),
              Text(
                'Polishing the doorknobs...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF32190D),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
