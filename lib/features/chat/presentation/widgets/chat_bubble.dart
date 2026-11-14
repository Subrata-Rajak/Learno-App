import 'package:flutter/material.dart';
import 'package:learno/core/theme/theme.dart';
import 'package:learno/features/chat/domain/entities/conversation_message.dart';

/// Message bubble displaying either user messages or assistant responses.
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    this.isStreaming = false,
  });

  final ConversationMessage message;
  final bool isStreaming;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'USER';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAssistantAvatar(),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isUser ? AppColors.deepInk : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppRadii.lg),
                  topRight: const Radius.circular(AppRadii.lg),
                  bottomLeft: Radius.circular(
                    isUser ? AppRadii.lg : AppRadii.xs,
                  ),
                  bottomRight: Radius.circular(
                    isUser ? AppRadii.xs : AppRadii.lg,
                  ),
                ),
                border: isUser
                    ? null
                    : Border.all(color: AppColors.outlineLight),
                boxShadow: isUser
                    ? const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : AppElevation.card,
              ),
              child: Column(
                crossAxisAlignment: isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!isUser)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                      child: Text(
                        'Learno',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.cobalt,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  if (message.content.isEmpty && isStreaming)
                    _buildPulsingCursor()
                  else
                    SelectableText(
                      message.content,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isUser
                            ? AppColors.textInverse
                            : AppColors.textPrimary,
                        height: 1.45,
                      ),
                    ),
                  if (isStreaming && !isUser && message.content.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xxs),
                      child: _buildStreamingPill(),
                    ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: AppSpacing.sm),
        ],
      ),
    );
  }

  Widget _buildAssistantAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: AppColors.cobalt,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowCobalt,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.auto_awesome_rounded,
        size: 18,
        color: AppColors.white,
      ),
    );
  }

  Widget _buildPulsingCursor() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.cobalt,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.cobalt.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.cobalt.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildStreamingPill() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.cobalt,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          'Thinking...',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textTertiary,
            fontSize: 11,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
