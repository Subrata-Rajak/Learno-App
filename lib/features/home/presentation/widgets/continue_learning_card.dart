import 'package:flutter/material.dart';
import 'package:learno/core/theme/theme.dart';
import 'package:learno/features/home/domain/entities/learning_journey.dart';
import 'package:learno/features/home/presentation/widgets/home_artwork.dart';

/// Visually rich, editorial-style card highlighting the learner's active journey.
class ContinueLearningCard extends StatelessWidget {
  const ContinueLearningCard({
    super.key,
    required this.journey,
    required this.onContinue,
  });

  final LearningJourney journey;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final categoryText = journey.category ?? 'Active Journey';
    final nextTopicText = journey.nextTopic ?? 'Continuing next concept';

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.borderCard,
        border: Border.all(color: AppColors.outlineLight, width: 1.0),
        boxShadow: AppElevation.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Top Accent Header Strip ---
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: const BoxDecoration(
              color: AppColors.warmIvory,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadii.card),
                topRight: Radius.circular(AppRadii.card),
              ),
              border: Border(
                bottom: BorderSide(color: AppColors.outlineLight, width: 1.0),
              ),
            ),
            child: Row(
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.cobalt,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'CONTINUE LEARNING',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.deepInk,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (journey.estimatedMinutesRemaining != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        color: AppColors.textSecondary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${journey.estimatedMinutesRemaining} min left',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // --- Editorial Content Body with Artwork ---
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryText.toUpperCase(),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.cobalt,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        journey.title,
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        journey.description,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.warmIvory,
                    borderRadius: AppRadii.borderMd,
                    border: Border.all(color: AppColors.outlineLight, width: 1),
                  ),
                  child: const ArchitectureJourneyArtwork(
                    width: 76,
                    height: 76,
                  ),
                ),
              ],
            ),
          ),

          // --- Next Up Milestone Callout ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F5FC),
                borderRadius: AppRadii.borderSm,
                border: Border.all(
                  color: AppColors.lavender.withValues(alpha: 0.4),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.lavender,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: AppColors.deepInk,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NEXT LESSON',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                        Text(
                          nextTopicText,
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.deepInk,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // --- Progress Indicator & Action Button ---
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overall Progress',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(journey.progressPercentage * 100).toInt()}% • ${journey.progressSummary}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.deepInk,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),

                // Custom Two-Tone Progress Bar
                ClipRRect(
                  borderRadius: AppRadii.borderPill,
                  child: Container(
                    height: 8,
                    width: double.infinity,
                    color: AppColors.warmIvoryDark,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: journey.progressPercentage,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.cobalt, Color(0xFF6E7FFF)],
                          ),
                          borderRadius: AppRadii.borderPill,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Primary "Continue learning" CTA
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cobalt,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: AppSpacing.lg,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadii.borderButton,
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue learning',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
