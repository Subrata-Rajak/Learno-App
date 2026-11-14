import 'package:flutter/material.dart';
import 'package:learno/core/theme/theme.dart';

/// Banner shown when an active stream was interrupted by a connection drop.
class ChatInterruptedBanner extends StatelessWidget {
  const ChatInterruptedBanner({
    super.key,
    required this.onReconcile,
    this.message,
  });

  final VoidCallback onReconcile;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.coral.withValues(alpha: 0.12),
        borderRadius: AppRadii.borderMd,
        border: Border.all(color: AppColors.coral.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppColors.coral, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message ?? 'Connection interrupted.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.deepInk,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: onReconcile,
            icon: const Icon(Icons.sync_rounded, size: 16),
            label: const Text('Sync'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.coral,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}
