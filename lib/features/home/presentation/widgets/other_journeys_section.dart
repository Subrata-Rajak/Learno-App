import 'package:flutter/material.dart';
import 'package:learno/core/theme/theme.dart';
import 'package:learno/features/home/domain/entities/learning_journey.dart';
import 'package:learno/features/home/presentation/widgets/home_artwork.dart';

/// Secondary section displaying other in-progress journeys with distinct visual accents.
class OtherJourneysSection extends StatelessWidget {
  const OtherJourneysSection({
    super.key,
    required this.journeys,
    required this.onJourneyTap,
    this.onViewAllTap,
  });

  final List<LearningJourney> journeys;
  final ValueChanged<LearningJourney> onJourneyTap;
  final VoidCallback? onViewAllTap;

  Color _getAccentColor(String id) {
    switch (id) {
      case 'backend-engineering':
        return AppColors.coral;
      case 'system-design':
        return AppColors.sunnyYellow;
      default:
        return AppColors.lavender;
    }
  }

  Widget _getArtwork(String id) {
    switch (id) {
      case 'backend-engineering':
        return const BackendJourneyArtwork(size: 48);
      case 'system-design':
        return const SystemDesignArtwork(size: 48);
      default:
        return const BackendJourneyArtwork(size: 48);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Section Header ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Explore More Journeys',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepInk,
                ),
              ),
              if (onViewAllTap != null)
                TextButton(
                  onPressed: onViewAllTap,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xxs,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View all',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.cobalt,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.cobalt,
                        size: 16,
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // --- Journey Cards List ---
          Column(
            children: journeys.map((journey) {
              final accentColor = _getAccentColor(journey.id);
              final artwork = _getArtwork(journey.id);
              final categoryText = journey.category ?? 'Journey';
              final nextText = journey.nextTopic != null
                  ? 'Next: ${journey.nextTopic}'
                  : journey.description;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Material(
                  color: AppColors.white,
                  borderRadius: AppRadii.borderMd,
                  child: InkWell(
                    onTap: () => onJourneyTap(journey),
                    borderRadius: AppRadii.borderMd,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        borderRadius: AppRadii.borderMd,
                        border: Border.all(
                          color: AppColors.outlineLight,
                          width: 1.0,
                        ),
                        boxShadow: AppElevation.subtle,
                      ),
                      child: Row(
                        children: [
                          artwork,
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: accentColor.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: AppRadii.borderPill,
                                      ),
                                      child: Text(
                                        categoryText.toUpperCase(),
                                        style: AppTypography.labelSmall
                                            .copyWith(
                                              color: AppColors.deepInk,
                                              fontSize: 8.5,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.5,
                                            ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      journey.progressSummary,
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  journey.title,
                                  style: AppTypography.titleSmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.deepInk,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  nextText,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 11.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.warmIvory,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.outlineLight,
                                width: 1.0,
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 13,
                              color: AppColors.deepInk,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
