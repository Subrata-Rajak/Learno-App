import 'package:flutter/material.dart';
import 'package:learno/core/theme/theme.dart';

/// Compact, expressive custom header for the Learno Home screen.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, this.userName = 'Alex', this.onAvatarTap});

  final String userName;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --- Brand Emblem & Greetings ---
          Expanded(
            child: Row(
              children: [
                // Stylized Learno Mark
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.cobalt,
                    borderRadius: AppRadii.borderSm,
                    boxShadow: AppElevation.cobaltGlow,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Greeting & Wordmark
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            'learno',
                            style: AppTypography.titleLarge.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: AppColors.deepInk,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.coral,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Good morning, $userName 👋',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- User Profile Avatar ---
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onAvatarTap,
              borderRadius: AppRadii.borderPill,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.sunnyYellow, Color(0xFFFFB84D)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                  boxShadow: AppElevation.subtle,
                ),
                child: Center(
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'L',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.deepInk,
                      fontWeight: FontWeight.w800,
                    ),
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
