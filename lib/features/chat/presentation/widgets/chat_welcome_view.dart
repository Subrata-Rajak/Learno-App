import 'package:flutter/material.dart';
import 'package:learno/core/theme/theme.dart';

/// Introductory welcome view displayed before a conversation begins.
class ChatWelcomeView extends StatelessWidget {
  const ChatWelcomeView({super.key, required this.onPromptSelected});

  final ValueChanged<String> onPromptSelected;

  static const List<Map<String, dynamic>> _suggestedPrompts = [
    {
      'title': 'Master Flutter BLoC',
      'subtitle': 'Learn state separation, reactive streams, and unit testing',
      'icon': Icons.layers_rounded,
      'color': AppColors.cobalt,
      'prompt':
          'I want to master Flutter state management using BLoC and clean architecture.',
    },
    {
      'title': 'Backend APIs with Node & TS',
      'subtitle': 'Build production REST endpoints and databases with Prisma',
      'icon': Icons.dns_rounded,
      'color': AppColors.coral,
      'prompt':
          'I want to learn how to build scalable backend APIs with Node.js, Express, and TypeScript.',
    },
    {
      'title': 'Dart Streams & Generators',
      'subtitle': 'Deep dive into async programming and reactive patterns',
      'icon': Icons.bolt_rounded,
      'color': AppColors.sunnyYellow,
      'prompt':
          'Teach me how Dart streams, controllers, and async generators work.',
    },
    {
      'title': 'Clean Architecture Fundamentals',
      'subtitle': 'Decouple domain entities, use cases, and data datasources',
      'icon': Icons.account_tree_rounded,
      'color': AppColors.lavender,
      'prompt':
          'Explain Clean Architecture principles and how to structure a modern mobile app.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.lg),
          _buildHero(),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Suggested Learning Paths',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ..._suggestedPrompts.map(
            (item) => _buildPromptCard(
              title: item['title'] as String,
              subtitle: item['subtitle'] as String,
              icon: item['icon'] as IconData,
              color: item['color'] as Color,
              prompt: item['prompt'] as String,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.borderLg,
        boxShadow: AppElevation.card,
        border: Border.all(color: AppColors.outlineLight),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6E7FFF),
                  AppColors.cobalt,
                  Color(0xFF2C3ED6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: AppElevation.cobaltGlow,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'What do you want to learn?',
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tell Learno your learning goals. Together we will clarify prerequisites and generate your personalized step-by-step roadmap.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPromptCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String prompt,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadii.borderMd,
        child: InkWell(
          borderRadius: AppRadii.borderMd,
          onTap: () => onPromptSelected(prompt),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: AppRadii.borderMd,
              border: Border.all(color: AppColors.outlineLight),
              boxShadow: AppElevation.card,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: AppRadii.borderSm,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
