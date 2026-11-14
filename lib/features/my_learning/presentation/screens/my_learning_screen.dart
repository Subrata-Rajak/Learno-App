import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:learno/app/router/app_routes.dart';
import 'package:learno/core/di/injection.dart';
import 'package:learno/core/theme/theme.dart';
import 'package:learno/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:learno/features/my_learning/presentation/widgets/my_learning_guest_view.dart';
import 'package:learno/features/my_learning/presentation/widgets/my_learning_journey_card.dart';
import 'package:learno/features/roadmap/presentation/bloc/roadmap_bloc.dart';
import 'package:learno/features/roadmap/presentation/bloc/roadmap_event.dart';
import 'package:learno/features/roadmap/presentation/bloc/roadmap_state.dart';

/// Screen displaying the user's active learning roadmaps and journeys.
class MyLearningScreen extends StatelessWidget {
  const MyLearningScreen({super.key, this.roadmapBloc});

  final RoadmapBloc? roadmapBloc;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isAuthenticated = authState is AuthAuthenticated;

    if (!isAuthenticated) {
      return const Scaffold(
        backgroundColor: AppColors.warmIvory,
        body: SafeArea(child: MyLearningGuestView()),
      );
    }

    if (roadmapBloc != null) {
      return BlocProvider<RoadmapBloc>.value(
        value: roadmapBloc!,
        child: const _MyLearningView(),
      );
    }

    return BlocProvider<RoadmapBloc>(
      create: (context) =>
          getIt<RoadmapBloc>()..add(const RoadmapOverviewRequested()),
      child: const _MyLearningView(),
    );
  }
}

class _MyLearningView extends StatelessWidget {
  const _MyLearningView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is AuthAuthenticated) {
          context.read<RoadmapBloc>().add(const RoadmapOverviewRequested());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.warmIvory,
        body: SafeArea(
          child: BlocBuilder<RoadmapBloc, RoadmapState>(
            builder: (context, state) {
              return switch (state) {
                RoadmapOverviewLoading() => const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.cobalt),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'Loading your journeys...',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                RoadmapOverviewEmpty() => _buildEmptyState(context),
                RoadmapOverviewError(:final message) =>
                  _buildErrorState(context, message),
                RoadmapOverviewLoaded(:final roadmaps) =>
                  _buildRoadmapsList(context, roadmaps),
                _ => const SizedBox.shrink(),
              };
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.md),
          Text(
            'My Learning',
            style: AppTypography.displayMedium.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppColors.deepInk,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Your enrolled tracks and learning roadmaps.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Center(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: AppRadii.borderCard,
                boxShadow: AppElevation.card,
                border: Border.all(color: AppColors.outlineLight),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: AppColors.skyBlueLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.cobalt,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No Active Roadmaps Yet',
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.deepInk,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Start a conversation with Ask Learno to create your first personalized curriculum.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.go(AppRoutes.askLearnoPath);
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: const Text('Start with Ask Learno'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cobalt,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: 12,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadii.borderButton,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.coral,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Failed to load learning tracks',
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
                  const RoadmapOverviewRequested(),
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
    );
  }

  Widget _buildRoadmapsList(BuildContext context, List dynamicRoadmaps) {
    return ListView.separated(
      padding: AppSpacing.screenPadding,
      itemCount: dynamicRoadmaps.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              Text(
                'My Learning',
                style: AppTypography.displayMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppColors.deepInk,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Your enrolled tracks and learning roadmaps.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          );
        }

        final roadmap = dynamicRoadmaps[index - 1];
        return MyLearningJourneyCard(
          roadmap: roadmap,
          onTap: () {
            context.push(AppRoutes.roadmapDetail(roadmap.id));
          },
        );
      },
    );
  }
}
