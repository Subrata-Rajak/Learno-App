import 'package:flutter/material.dart';
import 'package:learno/core/theme/theme.dart';
import 'package:learno/features/home/presentation/widgets/home_artwork.dart';

/// Memorable hero card anchoring the Ask Learno curiosity search and prompts.
class AskLearnoHero extends StatelessWidget {
  const AskLearnoHero({
    super.key,
    required this.onSearchTap,
    required this.onPromptSelected,
  });

  final VoidCallback onSearchTap;
  final ValueChanged<String> onPromptSelected;

  static const List<String> starterPrompts = [
    'Flutter architecture',
    'How AI works',
    'System design',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B4EFF), Color(0xFF2633A8), AppColors.deepInk],
          stops: [0.0, 0.55, 1.0],
        ),
        borderRadius: AppRadii.borderCard,
        boxShadow: const [
          BoxShadow(
            color: Color(0x383B4EFF),
            blurRadius: 24,
            offset: Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle background decorative star dust
          Positioned(
            right: 18,
            top: 14,
            child: Icon(
              Icons.star_rounded,
              color: AppColors.white.withValues(alpha: 0.12),
              size: 20,
            ),
          ),
          Positioned(
            left: 20,
            bottom: 60,
            child: Icon(
              Icons.auto_awesome,
              color: AppColors.sunnyYellow.withValues(alpha: 0.15),
              size: 16,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Headline & Discovery Artwork Row ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.14),
                              borderRadius: AppRadii.borderPill,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: AppColors.sunnyYellow,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'AI COMPANION',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.white,
                                    letterSpacing: 0.8,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Big questions.\nYour next big skill.',
                            style: AppTypography.headlineLarge.copyWith(
                              color: AppColors.white,
                              height: 1.15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Explore any concept, break down complexities, or practice with smart feedback.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.white.withValues(alpha: 0.82),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const HeroDiscoveryArtwork(size: 104),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // --- Genuinely Tappable Input-Style Action ---
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onSearchTap,
                    borderRadius: AppRadii.borderPill,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.sm,
                        AppSpacing.xs,
                        AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: AppRadii.borderPill,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x28000000),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: AppColors.cobalt,
                            size: 22,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              'What do you want to learn today?',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: AppColors.cobalt,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: AppColors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // --- Starter Prompt Chips ---
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _PromptChip(
                      label: starterPrompts[0],
                      icon: Icons.layers_outlined,
                      accentColor: AppColors.skyBlue,
                      onTap: () => onPromptSelected(starterPrompts[0]),
                    ),
                    _PromptChip(
                      label: starterPrompts[1],
                      icon: Icons.psychology_outlined,
                      accentColor: AppColors.sunnyYellow,
                      onTap: () => onPromptSelected(starterPrompts[1]),
                    ),
                    _PromptChip(
                      label: starterPrompts[2],
                      icon: Icons.hub_outlined,
                      accentColor: AppColors.lavender,
                      onTap: () => onPromptSelected(starterPrompts[2]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptChip extends StatelessWidget {
  const _PromptChip({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.borderPill,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.12),
            borderRadius: AppRadii.borderPill,
            border: Border.all(
              color: accentColor.withValues(alpha: 0.45),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: accentColor, size: 14),
              const SizedBox(width: 5),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
