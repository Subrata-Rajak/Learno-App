import 'package:flutter/material.dart';
import 'package:learno/core/theme/theme.dart';
import 'package:learno/features/roadmap/presentation/bloc/roadmap_bloc.dart';
import 'package:learno/features/roadmap/presentation/widgets/chat_roadmap_preview_card.dart';

/// Renders milestone status banners in the chat stream (Goal Created, Roadmap Generating, Roadmap Ready).
class ChatMilestoneBadge extends StatelessWidget {
  const ChatMilestoneBadge({
    super.key,
    this.goalId,
    this.isGeneratingRoadmap = false,
    this.roadmapId,
    this.onExploreJourney,
    this.roadmapBloc,
  });

  final String? goalId;
  final bool isGeneratingRoadmap;
  final String? roadmapId;
  final ValueChanged<String>? onExploreJourney;
  final RoadmapBloc? roadmapBloc;

  @override
  Widget build(BuildContext context) {
    if (roadmapId != null) {
      if (onExploreJourney != null) {
        return ChatRoadmapPreviewCard(
          roadmapId: roadmapId!,
          onExploreJourney: onExploreJourney!,
          roadmapBloc: roadmapBloc,
        );
      }

      return _buildCard(
        icon: Icons.check_circle_rounded,
        iconColor: AppColors.cobalt,
        backgroundColor: AppColors.lavenderLight,
        title: 'Roadmap Generated!',
        subtitle:
            'Learno has created your structured learning path. View your roadmap on the Home or Roadmap tabs.',
      );
    }

    if (isGeneratingRoadmap) {
      return _buildCard(
        icon: Icons.construction_rounded,
        iconColor: AppColors.coral,
        backgroundColor: AppColors.sunnyYellowLight,
        title: 'Building Your Roadmap...',
        subtitle:
            'Synthesizing topics, prerequisites, and milestone estimates.',
        isLoading: true,
      );
    }

    if (goalId != null) {
      return _buildCard(
        icon: Icons.flag_rounded,
        iconColor: AppColors.cobalt,
        backgroundColor: AppColors.skyBlueLight,
        title: 'Learning Goal Crystallized',
        subtitle: 'Target goal identified. Preparing custom curriculum.',
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildCard({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required String subtitle,
    bool isLoading = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppRadii.borderMd,
          border: Border.all(color: iconColor.withValues(alpha: 0.25)),
          boxShadow: AppElevation.card,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: iconColor.withValues(alpha: 0.3)),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: iconColor,
                      ),
                    )
                  : Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.deepInk,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
