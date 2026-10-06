import 'package:flutter/material.dart';

class EmptyView extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onRefresh;
  final String buttonLabel;

  const EmptyView({
    super.key,
    this.title = 'NO POKÉMON DETECTED',
    this.description = 'No specimen entries match your current search or filter query.',
    required this.onRefresh,
    this.buttonLabel = 'RESET FILTERS',
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
          border: Border.all(color: const Color(0xFF37474F), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.radar_rounded,
              size: 56,
              color: Colors.amberAccent,
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: Colors.amberAccent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                buttonLabel,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.cyanAccent,
                side: const BorderSide(color: Colors.cyanAccent, width: 1.5),
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
