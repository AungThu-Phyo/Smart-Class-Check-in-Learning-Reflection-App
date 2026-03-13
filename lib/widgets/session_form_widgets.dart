import 'package:flutter/material.dart';

import '../services/location_service.dart';

class SessionIntroCard extends StatelessWidget {
  const SessionIntroCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(subtitle),
          ],
        ),
      ),
    );
  }
}

class LocationStatusCard extends StatelessWidget {
  const LocationStatusCard({
    super.key,
    required this.location,
    required this.onCapture,
  });

  final LocationSnapshot? location;
  final Future<void> Function() onCapture;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'GPS Location',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    onCapture();
                  },
                  icon: const Icon(Icons.my_location_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              location == null
                  ? 'Location has not been captured yet.'
                  : 'Lat ${location!.latitude.toStringAsFixed(5)}, Lng ${location!.longitude.toStringAsFixed(5)}, Accuracy ${location!.accuracyMeters.toStringAsFixed(1)}m',
            ),
          ],
        ),
      ),
    );
  }
}
