import 'package:flutter/material.dart';
import 'package:learno/core/theme/theme.dart';

/// Fixed bottom navigation bar featuring a distinctive central "Ask Learno" action.
class LearnoBottomNav extends StatelessWidget {
  const LearnoBottomNav({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.outlineLight, width: 1.0),
        ),
        boxShadow: AppElevation.floating,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 6,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 0: Home
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: currentIndex == 0,
                onTap: () => onItemSelected(0),
              ),

              // 1: My Learning
              _NavItem(
                icon: Icons.auto_stories_outlined,
                label: 'My Learning',
                isSelected: currentIndex == 1,
                onTap: () => onItemSelected(1),
              ),

              // 2: Ask Learno (Prominent Center Cobalt Button)
              _CenterAskButton(
                isSelected: currentIndex == 2,
                onTap: () => onItemSelected(2),
              ),

              // 3: Progress
              _NavItem(
                icon: Icons.insights_rounded,
                label: 'Progress',
                isSelected: currentIndex == 3,
                onTap: () => onItemSelected(3),
              ),

              // 4: Profile
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                isSelected: currentIndex == 4,
                onTap: () => onItemSelected(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.cobalt : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.borderSm,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 3),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: color,
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.cobalt : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterAskButton extends StatelessWidget {
  const _CenterAskButton({required this.isSelected, required this.onTap});

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.borderPill,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
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
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Ask Learno',
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected ? AppColors.cobalt : AppColors.deepInk,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.cobalt : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
