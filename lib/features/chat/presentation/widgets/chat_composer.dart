import 'package:flutter/material.dart';
import 'package:learno/core/theme/theme.dart';

/// Floating message input composer with dynamic send and cancel actions.
class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.onSend,
    required this.onCancel,
    this.isStreaming = false,
    this.isEnabled = true,
  });

  final ValueChanged<String> onSend;
  final VoidCallback onCancel;
  final bool isStreaming;
  final bool isEnabled;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.isEnabled || widget.isStreaming) {
      return;
    }
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.warmIvory,
        border: Border(
          top: BorderSide(color: AppColors.outlineLight.withValues(alpha: 0.5)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.borderLg,
            border: Border.all(color: AppColors.outline),
            boxShadow: AppElevation.card,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: widget.isEnabled && !widget.isStreaming,
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSubmit(),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.isStreaming
                        ? 'Learno is thinking...'
                        : 'Ask Learno what you want to learn...',
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xxs),
              if (widget.isStreaming)
                _buildActionButton(
                  icon: Icons.stop_rounded,
                  color: AppColors.coral,
                  onPressed: widget.onCancel,
                  tooltip: 'Stop response',
                )
              else
                _buildActionButton(
                  icon: Icons.arrow_upward_rounded,
                  color: _hasText && widget.isEnabled
                      ? AppColors.cobalt
                      : AppColors.outline,
                  onPressed: _hasText && widget.isEnabled
                      ? _handleSubmit
                      : null,
                  tooltip: 'Send message',
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    required String tooltip,
  }) {
    final isInteractive = onPressed != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4, right: 2),
      child: Material(
        color: isInteractive ? color : color.withValues(alpha: 0.3),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Tooltip(
            message: tooltip,
            child: SizedBox(
              width: 36,
              height: 36,
              child: Icon(icon, color: AppColors.white, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}
