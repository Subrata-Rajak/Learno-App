import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learno/core/di/injection.dart';
import 'package:learno/core/theme/theme.dart';
import 'package:learno/features/roadmap/domain/entities/roadmap.dart';
import 'package:learno/features/roadmap/presentation/bloc/roadmap_bloc.dart';
import 'package:learno/features/roadmap/presentation/bloc/roadmap_event.dart';
import 'package:learno/features/roadmap/presentation/bloc/roadmap_state.dart';
import 'package:learno/features/roadmap/presentation/widgets/topic_step_tile.dart';

/// Full-screen dedicated view presenting a complete learning roadmap journey.
class RoadmapDetailScreen extends StatelessWidget {
  const RoadmapDetailScreen({
    super.key,
    required this.roadmapId,
    this.roadmapBloc,
  });

  final String roadmapId;
  final RoadmapBloc? roadmapBloc;

  @override
  Widget build(BuildContext context) {
    if (roadmapBloc != null) {
      return BlocProvider<RoadmapBloc>.value(
        value: roadmapBloc!,
        child: _RoadmapDetailView(roadmapId: roadmapId),
      );
    }

    return BlocProvider<RoadmapBloc>(
      create: (context) => getIt<RoadmapBloc>(),
      child: _RoadmapDetailView(roadmapId: roadmapId),
    );
  }
}

class _RoadmapDetailView extends StatefulWidget {
  const _RoadmapDetailView({required this.roadmapId});

  final String roadmapId;

  @override
  State<_RoadmapDetailView> createState() => _RoadmapDetailViewState();
}

class _RoadmapDetailViewState extends State<_RoadmapDetailView> {
  @override
  void initState() {
    super.initState();
    context.read<RoadmapBloc>().add(RoadmapDetailRequested(widget.roadmapId));
  }

  @override
  void didUpdateWidget(covariant _RoadmapDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.roadmapId != widget.roadmapId) {
      context.read<RoadmapBloc>().add(RoadmapDetailRequested(widget.roadmapId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        backgroundColor: AppColors.warmIvory,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.deepInk,
          ),
          tooltip: 'Back',
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
        title: Text(
          'Learning Roadmap',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.deepInk,
          ),
        ),
      ),
      body: BlocBuilder<RoadmapBloc, RoadmapState>(
        builder: (context, state) {
          return switch (state) {
            RoadmapDetailLoading() => const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.cobalt),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Loading curriculum...',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            RoadmapDetailError(:final message) => Center(
              child: Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: AppColors.coral,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Failed to load roadmap',
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepInk,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      message,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<RoadmapBloc>().add(
                          RoadmapDetailRequested(widget.roadmapId),
                        );
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cobalt,
                        foregroundColor: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            RoadmapDetailLoaded(:final roadmap) => _buildContent(roadmap),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  Widget _buildContent(Roadmap roadmap) {
    final firstUncompletedIndex = roadmap.topics.indexWhere(
      (t) => !t.isCompleted,
    );

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      children: [
        const SizedBox(height: AppSpacing.sm),

        // Category Tag
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.skyBlue,
              borderRadius: AppRadii.borderPill,
            ),
            child: Text(
              'CURRICULUM JOURNEY',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.cobaltDark,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Roadmap Title
        Text(
          roadmap.title,
          style: AppTypography.displaySmall.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.deepInk,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),

        // Roadmap Description
        Text(
          roadmap.description,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Progress Card
        _buildProgressCard(roadmap),
        const SizedBox(height: AppSpacing.xl),

        // Topics Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TOPICS IN THIS JOURNEY',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
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
        const SizedBox(height: AppSpacing.md),

        // Topics List
        ...roadmap.topics.asMap().entries.map((entry) {
          final index = entry.key;
          final topic = entry.value;
          final isFirst = index == 0;
          final isLast = index == roadmap.topics.length - 1;
          final isCurrent = index == firstUncompletedIndex;

          return TopicStepTile(
            topic: topic,
            isFirst: isFirst,
            isLast: isLast,
            isCurrent: isCurrent,
          );
        }),

        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildProgressCard(Roadmap roadmap) {
    final progressPct = (roadmap.progressPercentage * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.borderCard,
        border: Border.all(color: AppColors.outlineLight),
        boxShadow: AppElevation.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Progress',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepInk,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: roadmap.completedTopics == roadmap.totalTopics
                      ? AppColors.lavenderLight
                      : AppColors.skyBlueLight,
                  borderRadius: AppRadii.borderPill,
                ),
                child: Text(
                  roadmap.completedTopics == roadmap.totalTopics
                      ? 'COMPLETED'
                      : '$progressPct% DONE',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.cobalt,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${roadmap.completedTopics} of ${roadmap.totalTopics} topics completed',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: AppRadii.borderPill,
            child: Container(
              height: 8,
              width: double.infinity,
              color: AppColors.warmIvoryDark,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: roadmap.progressPercentage,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.cobalt, AppColors.cobaltLight],
                    ),
                    borderRadius: AppRadii.borderPill,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
