import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learno/app/router/app_routes.dart';
import 'package:learno/core/theme/theme.dart';

/// Presentation view displayed to unauthenticated guest visitors.
class ChatGuestView extends StatelessWidget {
  const ChatGuestView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xxl),
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.lavenderLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.lavender, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowCobalt,
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.school_rounded,
                size: 44,
                color: AppColors.cobalt,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Meet Learno',
            style: AppTypography.displaySmall.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Your intelligent conversational learning companion.',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Sign in to explore custom roadmaps, track your completed topics, and access curated resources tailored to your goals.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          _buildFeaturePill(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Conversational Goal Discovery',
            color: AppColors.cobalt,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildFeaturePill(
            icon: Icons.map_outlined,
            title: 'Custom Step-by-Step Roadmaps',
            color: AppColors.coral,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildFeaturePill(
            icon: Icons.auto_stories_outlined,
            title: 'Curated Multi-Format Resources',
            color: AppColors.sunnyYellow,
          ),
          const SizedBox(height: AppSpacing.xxl),
          ElevatedButton(
            onPressed: () {
              context.push(
                '${AppRoutes.loginPath}?${AppRoutes.redirectParam}=${Uri.encodeComponent(AppRoutes.askLearnoPath)}',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cobalt,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
              elevation: 2,
            ),
            child: Text(
              'Sign In to Start Learning',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () {
              context.push(
                '${AppRoutes.registerPath}?${AppRoutes.redirectParam}=${Uri.encodeComponent(AppRoutes.askLearnoPath)}',
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            ),
            child: Text(
              'Don\'t have an account? Sign up',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.cobalt,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildFeaturePill({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.borderMd,
        border: Border.all(color: AppColors.outlineLight),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.md),
          Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
