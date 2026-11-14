import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learno/app/router/app_routes.dart';
import 'package:learno/core/theme/theme.dart';

/// Renders an inviting landing state for unauthenticated guests in the My Learning tab.
class MyLearningGuestView extends StatelessWidget {
  const MyLearningGuestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadii.borderCard,
            border: Border.all(color: AppColors.outlineLight),
            boxShadow: AppElevation.card,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.skyBlueLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: AppColors.cobalt,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Track Your Learning Journeys',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.deepInk,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Sign in to access your synthesized roadmaps, track completed milestones, and explore curated learning resources.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final returnTarget = Uri.encodeComponent(
                      AppRoutes.myLearningPath,
                    );
                    context.push(
                      '${AppRoutes.loginPath}?${AppRoutes.redirectParam}=$returnTarget',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cobalt,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadii.borderButton,
                    ),
                  ),
                  child: Text(
                    'Sign In',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.push(AppRoutes.registerPath);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.deepInk,
                    side: const BorderSide(color: AppColors.outlineStrong),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadii.borderButton,
                    ),
                  ),
                  child: Text(
                    'Create Account',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
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
