import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learno/core/theme/theme.dart';
import 'package:learno/features/home/data/datasources/home_local_datasource.dart';
import 'package:learno/features/home/data/repositories/home_repository_impl.dart';
import 'package:learno/features/home/domain/usecases/get_home_journeys.dart';
import 'package:learno/features/home/presentation/bloc/home_bloc.dart';
import 'package:learno/features/home/presentation/widgets/ask_learno_hero.dart';
import 'package:learno/features/home/presentation/widgets/continue_learning_card.dart';
import 'package:learno/features/home/presentation/widgets/home_header.dart';
import 'package:learno/features/home/presentation/widgets/learno_bottom_nav.dart';
import 'package:learno/features/home/presentation/widgets/other_journeys_section.dart';

/// The primary Home screen for Learno, managed by HomeBloc and Clean Architecture.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.homeBloc});

  final HomeBloc? homeBloc;

  @override
  Widget build(BuildContext context) {
    if (homeBloc != null) {
      return BlocProvider<HomeBloc>.value(
        value: homeBloc!,
        child: const _HomeView(),
      );
    }

    return BlocProvider<HomeBloc>(
      create: (context) => HomeBloc(
        getHomeJourneys: GetHomeJourneys(
          HomeRepositoryImpl(dataSource: const HomeMockDataSource()),
        ),
      )..add(const HomeLoadRequested()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  int _currentNavIndex = 0;

  void _showFeedback(
    String message, {
    IconData icon = Icons.info_outline_rounded,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.deepInk,
        elevation: 6,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.none,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        content: Row(
          children: [
            Icon(icon, color: AppColors.sunnyYellow, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleNavSelect(int index) {
    setState(() {
      _currentNavIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        _showFeedback(
          'My Learning journeys library is coming soon!',
          icon: Icons.auto_stories_rounded,
        );
        break;
      case 2:
        _showFeedback(
          'Ask Learno conversational mentor is ready for upcoming checkpoints!',
          icon: Icons.auto_awesome_rounded,
        );
        break;
      case 3:
        _showFeedback(
          'Skill mastery analytics & progress tracking coming soon!',
          icon: Icons.insights_rounded,
        );
        break;
      case 4:
        _showFeedback(
          'Learner profile & study preferences coming soon!',
          icon: Icons.person_rounded,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return switch (state) {
              HomeInitial() || HomeLoading() => const _LoadingView(),
              HomeError(:final message) => _ErrorView(
                message: message,
                onRetry: () =>
                    context.read<HomeBloc>().add(const HomeLoadRequested()),
              ),
              HomeLoaded(:final journeys) => SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Header (Brand mark, Greeting, Profile avatar)
                    HomeHeader(
                      userName: 'Alex',
                      onAvatarTap: () => _showFeedback(
                        'Signed in as Alex (alex@learno.app)',
                        icon: Icons.account_circle_outlined,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    // 2. Ask Learno Hero (Headline, Discovery Artwork, Search Input, Prompt Chips)
                    AskLearnoHero(
                      onSearchTap: () => _showFeedback(
                        'Ask Learno: What would you like to explore today?',
                        icon: Icons.search_rounded,
                      ),
                      onPromptSelected: (prompt) => _showFeedback(
                        'Exploring: "$prompt"...',
                        icon: Icons.auto_awesome_rounded,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // 3. Continue Learning (Featured Active Journey)
                    ContinueLearningCard(
                      journey: journeys.activeJourney,
                      onContinue: () => _showFeedback(
                        'Resuming topic: "${journeys.activeJourney.nextTopic ?? journeys.activeJourney.title}"',
                        icon: Icons.play_arrow_rounded,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    // 4. Other Journeys (Secondary differentiated cards)
                    OtherJourneysSection(
                      journeys: journeys.secondaryJourneys,
                      onJourneyTap: (journey) => _showFeedback(
                        'Opening journey: "${journey.title}"',
                        icon: Icons.book_outlined,
                      ),
                      onViewAllTap: () => _showFeedback(
                        'Browsing all 14 available learning tracks...',
                        icon: Icons.grid_view_rounded,
                      ),
                    ),

                    // Bottom spacing clearance
                    const SizedBox(height: AppSpacing.huge),
                  ],
                ),
              ),
            };
          },
        ),
      ),
      bottomNavigationBar: LearnoBottomNav(
        currentIndex: _currentNavIndex,
        onItemSelected: _handleNavSelect,
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.cobalt),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Preparing your learning space...',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadii.borderCard,
            border: Border.all(color: AppColors.outlineLight, width: 1.0),
            boxShadow: AppElevation.subtle,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.coral.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  color: AppColors.coral,
                  size: 26,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Something went wrong',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepInk,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cobalt,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
