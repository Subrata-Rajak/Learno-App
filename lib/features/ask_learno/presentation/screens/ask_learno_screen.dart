import 'package:flutter/material.dart';
import 'package:learno/core/theme/theme.dart';

/// Lightweight placeholder screen for the central "Ask Learno" destination.
///
/// Clearly identified as temporary and ready to be replaced by the future
/// conversational feature without restructuring the app shell.
class AskLearnoScreen extends StatelessWidget {
  const AskLearnoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.md),
              Text(
                'Ask Learno',
                style: AppTypography.displayMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Your conversational AI mentor.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppRadii.borderLg,
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
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF5A6CFF),
                            AppColors.cobalt,
                            Color(0xFF3345E6),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: AppElevation.cobaltGlow,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'AI Mentor Coming Soon',
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Conversational roadmap generation, topic explanations, and interactive learning dialogues will arrive in upcoming checkpoints.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.sunnyYellow.withValues(alpha: 0.35),
                        borderRadius: AppRadii.borderPill,
                      ),
                      child: Text(
                        'UPCOMING FEATURE PLACEHOLDER',
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
            ],
          ),
        ),
      ),
    );
  }
}
