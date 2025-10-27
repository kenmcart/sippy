import 'package:flutter/material.dart';

class AgeVerificationDialog extends StatelessWidget {
  final VoidCallback onOver21;
  final VoidCallback onUnder21;

  const AgeVerificationDialog({
    super.key,
    required this.onOver21,
    required this.onUnder21,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent dismissing by tapping outside or back button
      child: AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.wine_bar, size: 28),
            SizedBox(width: 12),
            Text('Age Verification'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you 21 years of age or older?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Text(
              'This app contains information about alcoholic beverages.',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'If you select "No", only non-alcoholic drinks will be shown.',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: onUnder21,
            child: const Text('No, I\'m under 21'),
          ),
          FilledButton(
            onPressed: onOver21,
            child: const Text('Yes, I\'m 21+'),
          ),
        ],
      ),
    );
  }
}
