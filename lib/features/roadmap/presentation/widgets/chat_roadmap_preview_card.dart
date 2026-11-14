import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learno/core/di/injection.dart';
import 'package:learno/core/theme/theme.dart';
import 'package:learno/features/roadmap/domain/entities/roadmap.dart';
import 'package:learno/features/roadmap/presentation/bloc/roadmap_bloc.dart';
import 'package:learno/features/roadmap/presentation/bloc/roadmap_event.dart';
import 'package:learno/features/roadmap/presentation/bloc/roadmap_state.dart';

/// Visually rich preview card rendered in the Ask Learno conversation stream
/// once a roadmap has been synthesized by the backend.
class ChatRoadmapPreviewCard extends StatelessWidget {
  const ChatRoadmapPreviewCard({
    super.key,
    required this.roadmapId,
    required this.onExploreJourney,
    this.roadmapBloc,
  });

  final String roadmapId;
  final ValueChanged<String> onExploreJourney;
  final RoadmapBloc? roadmapBloc;

  @override
  Widget build(BuildContext context) {
    if (roadmapBloc != null) {
      return BlocProvider<RoadmapBloc>.value(
        value: roadmapBloc!,
        child: _ChatRoadmapPreviewView(
          roadmapId: roadmapId,
          onExploreJourney: onExploreJourney,
        ),
      );
    }

    return BlocProvider<RoadmapBloc>(
      create: (context) =>
          getIt<RoadmapBloc>()..add(RoadmapDetailRequested(roadmapId)),
      child: _ChatRoadmapPreviewView(
        roadmapId: roadmapId,
        onExploreJourney: onExploreJourney,
      ),
    );
  }
}

class _ChatRoadmapPreviewView extends StatefulWidget {
  const _ChatRoadmapPreviewView({
    required this.roadmapId,
    required this.onExploreJourney,
  });

  final String roadmapId;
  final ValueChanged<String> onExploreJourney;

  @override
  State<_ChatRoadmapPreviewView> createState() =>
      _ChatRoadmapPreviewViewState();
}

class _ChatRoadmapPreviewViewState extends State<_ChatRoadmapPreviewView> {
  @override
  void didUpdateWidget(covariant _ChatRoadmapPreviewView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.roadmapId != widget.roadmapId) {
      context.read<RoadmapBloc>().add(
        RoadmapDetailRequested(widget.roadmapId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: BlocBuilder<RoadmapBloc, RoadmapState>(
        builder: (context, state) {
          return switch (state) {
            RoadmapDetailLoading() => _buildLoadingCard(),
            RoadmapDetailError(:final message) => _buildErrorCard(context, message),
            RoadmapDetailLoaded(:final roadmap) => _buildLoadedCard(roadmap),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.borderMd,
        border: Border.all(color: AppColors.cobalt.withValues(alpha: 0.2)),
        boxShadow: AppElevation.card,
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.cobalt,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Fetching roadmap curriculum...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.borderMd,
        border: Border.all(color: AppColors.coral.withValues(alpha: 0.4)),
        boxShadow: AppElevation.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.coral,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Unable to load roadmap preview',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepInk,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            message,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                context.read<RoadmapBloc>().add(
                  RoadmapDetailRequested(widget.roadmapId),
                );
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.cobalt,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedCard(Roadmap roadmap) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.borderCard,
        border: Border.all(
          color: AppColors.cobalt.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: AppElevation.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.lavenderLight,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadii.card - 1),
                topRight: Radius.circular(AppRadii.card - 1),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_stories_rounded,
                  color: AppColors.cobalt,
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'ROADMAP READY',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.cobaltDark,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    fontSize: 10,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: AppRadii.borderPill,
                  ),
                  child: Text(
                    '${roadmap.totalTopics} Topics',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.deepInk,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content Body
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roadmap.title,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.deepInk,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  roadmap.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                if (roadmap.topics.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.warmIvory,
                      borderRadius: AppRadii.borderSm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FIRST STEPS',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        ...roadmap.topics.take(2).map(
                              (topic) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.xxs,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: const BoxDecoration(
                                        color: AppColors.skyBlue,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${topic.sequence}',
                                          style: const TextStyle(
                                            color: AppColors.cobaltDark,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Expanded(
                                      child: Text(
                                        topic.title,
                                        style:
                                            AppTypography.bodySmall.copyWith(
                                          color: AppColors.deepInk,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.md),

                // Primary Action Button: Explore Journey
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => widget.onExploreJourney(roadmap.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cobalt,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: AppSpacing.md,
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
                          'Explore Journey',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: AppColors.white,
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
