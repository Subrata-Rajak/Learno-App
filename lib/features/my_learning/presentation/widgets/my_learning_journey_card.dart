import 'package:flutter/material.dart';
import 'package:learno/core/theme/theme.dart';
import 'package:learno/features/roadmap/domain/entities/roadmap.dart';

/// Card item representing an active learning roadmap in the My Learning tab.
class MyLearningJourneyCard extends StatelessWidget {
  const MyLearningJourneyCard({
    super.key,
    required this.roadmap,
    required this.onTap,
  });

  final Roadmap roadmap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progressPct = (roadmap.progressPercentage * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.borderCard,
        border: Border.all(color: AppColors.outlineLight),
        boxShadow: AppElevation.card,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Meta Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.skyBlue,
                        borderRadius: AppRadii.borderPill,
                      ),
                      child: Text(
                        'LEARNING PATH',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.cobaltDark,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    Text(
                      '${roadmap.totalTopics} topics',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),

                // Roadmap Title
                Text(
                  roadmap.title,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.deepInk,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),

                // Roadmap Description
                Text(
                  roadmap.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Progress Bar & Stat
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${roadmap.completedTopics} of ${roadmap.totalTopics} completed',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$progressPct%',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.cobalt,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                ClipRRect(
                  borderRadius: AppRadii.borderPill,
                  child: Container(
                    height: 6,
                    width: double.infinity,
                    color: AppColors.warmIvoryDark,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: roadmap.progressPercentage,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.cobalt,
                          borderRadius: AppRadii.borderPill,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Action Prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'View Roadmap',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.cobalt,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.cobalt,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
