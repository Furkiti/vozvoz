import 'package:flutter/material.dart';

class CurrentPrayerWidget extends StatelessWidget {
  final String currentPrayer;
  final String nextPrayer;
  final String remainingTime;
  final String location;
  final bool hasLocationError;
  final VoidCallback? onRetryLocation;

  const CurrentPrayerWidget({
    super.key,
    required this.currentPrayer,
    required this.nextPrayer,
    required this.remainingTime,
    required this.location,
    this.hasLocationError = false,
    this.onRetryLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  hasLocationError ? Icons.location_off : Icons.location_on,
                  size: 16,
                  color: hasLocationError ? Colors.red : null,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: hasLocationError ? Colors.red : null,
                        ),
                  ),
                ),
                if (hasLocationError && onRetryLocation != null)
                  TextButton.icon(
                    onPressed: onRetryLocation,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Tekrar Dene'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 32),
                    ),
                  ),
              ],
            ),
            if (!hasLocationError) ...[
              const SizedBox(height: 16),
              Text(
                'Şu anki vakit: $currentPrayer',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Sonraki vakit: $nextPrayer',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Kalan süre: $remainingTime',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ],
        ),
      ),
    );
  }
} 