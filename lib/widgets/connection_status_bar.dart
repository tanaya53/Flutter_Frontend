import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class ConnectionStatusBar extends StatelessWidget {
  final bool isOnline;
  final int pendingSyncCount;
  final VoidCallback? onSyncTap;

  const ConnectionStatusBar({
    super.key,
    this.isOnline = true,
    this.pendingSyncCount = 0,
    this.onSyncTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isOnline && pendingSyncCount == 0) {
      return const SizedBox.shrink();
    }

    final color = isOnline ? AppColors.warning : AppColors.textSecondary;
    return Container(
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isOnline ? Icons.sync : Icons.cloud_off,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                isOnline
                    ? 'Syncing offline records ($pendingSyncCount pending)...'
                    : 'Offline Mode: Data saved locally. Auto-syncs when connected.',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (isOnline && pendingSyncCount > 0 && onSyncTap != null)
            InkWell(
              onTap: onSyncTap,
              child: const Text(
                'Sync Now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
