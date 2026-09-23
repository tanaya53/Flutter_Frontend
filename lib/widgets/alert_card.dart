import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AlertCard extends StatelessWidget {
  final String title;
  final String description;
  final String severity; // LOW, MEDIUM, HIGH, CRITICAL
  final VoidCallback? onAction;
  final String? actionLabel;

  const AlertCard({
    super.key,
    required this.title,
    required this.description,
    this.severity = 'MEDIUM',
    this.onAction,
    this.actionLabel,
  });

  Color get _alertColor {
    switch (severity.toUpperCase()) {
      case 'CRITICAL':
      case 'HIGH':
        return AppColors.error;
      case 'MEDIUM':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  IconData get _alertIcon {
    switch (severity.toUpperCase()) {
      case 'CRITICAL':
      case 'HIGH':
        return Icons.emergency_outlined;
      case 'MEDIUM':
        return Icons.warning_amber_rounded;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: _alertColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _alertColor.withOpacity(0.35), width: 1.2),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_alertIcon, color: _alertColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _alertColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        severity.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: _alertColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.3),
                ),
                if (onAction != null && actionLabel != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onAction,
                      style: TextButton.styleFrom(
                        foregroundColor: _alertColor,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        actionLabel!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
