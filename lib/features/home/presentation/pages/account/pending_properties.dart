import 'package:flutter/material.dart';

class PendingPropertiesPage extends StatelessWidget {
  const PendingPropertiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pending Properties',
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
      body: const Center(
        child: Text(
          'List of properties waiting for approval\n'
          '(Approve / Reject buttons will appear here)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
