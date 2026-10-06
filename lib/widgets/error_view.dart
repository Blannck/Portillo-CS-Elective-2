import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ErrorView({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: const Color(0xFF1E272C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFF1744), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 56,
              color: Color(0xFFFF5252),
            ),
            const SizedBox(height: 14),
            const Text(
              'COMMUNICATION ERROR',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Color(0xFFFF5252),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              errorMessage,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'RECONNECT SENSOR',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC0A2D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
