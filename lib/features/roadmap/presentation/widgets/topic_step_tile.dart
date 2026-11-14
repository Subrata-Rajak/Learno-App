import 'package:flutter/material.dart';
import 'package:learno/core/theme/theme.dart';
import 'package:learno/features/roadmap/domain/entities/roadmap_topic.dart';

/// Renders a single topic step in the roadmap journey timeline.
class TopicStepTile extends StatelessWidget {
  const TopicStepTile({
    super.key,
    required this.topic,
    this.isFirst = false,
    this.isLast = false,
    this.isCurrent = false,
  });

  final RoadmapTopic topic;
  final bool isFirst;
  final bool isLast;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final isCompleted = topic.isCompleted;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Left Timeline Rail ---
          SizedBox(
            width: 36,
            child: Column(
              children: [
                // Top connector line
                Container(
                  width: 2,
                  height: 12,
                  color: isFirst
                      ? Colors.transparent
                      : (isCompleted ? AppColors.cobalt : AppColors.outline),
                ),
                // Indicator Node
                _buildIndicatorNode(isCompleted),
                // Bottom connector line
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast
                        ? Colors.transparent
                        : (isCompleted ? AppColors.cobalt : AppColors.outline),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // --- Step Content Card ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppRadii.borderMd,
                  border: Border.all(
                    color: isCompleted
                        ? AppColors.cobalt.withValues(alpha: 0.3)
                        : (isCurrent
                            ? AppColors.cobalt.withValues(alpha: 0.5)
                            : AppColors.outlineLight),
                    width: isCurrent ? 1.5 : 1.0,
                  ),
                  boxShadow: AppElevation.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step Meta Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppColors.lavenderLight
                                : (isCurrent
                                    ? AppColors.skyBlue
                                    : AppColors.warmIvoryDark),
                            borderRadius: AppRadii.borderPill,
                          ),
                          child: Text(
                            'STEP ${topic.sequence}',
                            style: AppTypography.labelSmall.copyWith(
                              color: isCompleted
                                  ? AppColors.cobaltDark
                                  : (isCurrent
                                      ? AppColors.cobalt
                                      : AppColors.textSecondary),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        _buildStatusBadge(isCompleted),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Topic Title
                    Text(
                      topic.title,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.deepInk,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),

                    // Topic Description
                    Text(
                      topic.description,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorNode(bool isCompleted) {
    if (isCompleted) {
      return Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: AppColors.cobalt,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          color: AppColors.white,
          size: 16,
        ),
      );
    }

    if (isCurrent) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.cobalt, width: 2.5),
        ),
        child: Center(
          child: Text(
            '${topic.sequence}',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.cobalt,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.outline, width: 1.5),
      ),
      child: Center(
        child: Text(
          '${topic.sequence}',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isCompleted) {
    if (isCompleted) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.cobalt,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            'Completed',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.cobalt,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }

    if (isCurrent) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.coral,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Up Next',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.coral,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }

    return Text(
      'Pending',
      style: AppTypography.labelSmall.copyWith(
        color: AppColors.textTertiary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
