import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:learno/app/router/app_routes.dart';
import 'package:learno/core/di/injection.dart';
import 'package:learno/core/theme/theme.dart';
import 'package:learno/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:learno/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:learno/features/chat/presentation/bloc/chat_event.dart';
import 'package:learno/features/chat/presentation/bloc/chat_state.dart';
import 'package:learno/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:learno/features/chat/presentation/widgets/chat_composer.dart';
import 'package:learno/features/chat/presentation/widgets/chat_guest_view.dart';
import 'package:learno/features/chat/presentation/widgets/chat_interrupted_banner.dart';
import 'package:learno/features/chat/presentation/widgets/chat_milestone_badge.dart';
import 'package:learno/features/chat/presentation/widgets/chat_welcome_view.dart';

/// Primary conversational screen for the "Ask Learno" destination.
class AskLearnoScreen extends StatelessWidget {
  const AskLearnoScreen({super.key, this.chatBloc});

  final ChatBloc? chatBloc;

  @override
  Widget build(BuildContext context) {
    if (chatBloc != null) {
      return BlocProvider<ChatBloc>.value(
        value: chatBloc!,
        child: const _AskLearnoView(),
      );
    }

    return BlocProvider<ChatBloc>(
      create: (context) => getIt<ChatBloc>(),
      child: const _AskLearnoView(),
    );
  }
}

class _AskLearnoView extends StatefulWidget {
  const _AskLearnoView();

  @override
  State<_AskLearnoView> createState() => _AskLearnoViewState();
}

class _AskLearnoViewState extends State<_AskLearnoView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    context.read<ChatBloc>().add(
      ChatStarted(isAuthenticated: authState is AuthAuthenticated),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, authState) {
            context.read<ChatBloc>().add(
              ChatStarted(isAuthenticated: authState is AuthAuthenticated),
            );
          },
        ),
        BlocListener<ChatBloc, ChatState>(
          listenWhen: (previous, current) =>
              previous.messages.length != current.messages.length ||
              (previous.isStreaming && !current.isStreaming),
          listener: (context, state) {
            _scrollToBottom();
          },
        ),
      ],
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          final isGuest = state.status == ChatStatus.guest;

          return Scaffold(
            backgroundColor: AppColors.warmIvory,
            appBar: _buildAppBar(context, state),
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Expanded(child: _buildBody(context, state)),
                  if (state.isStreamInterrupted)
                    ChatInterruptedBanner(
                      message: state.errorMessage,
                      onReconcile: () {
                        context.read<ChatBloc>().add(
                          const ChatReconcileRequested(),
                        );
                      },
                    ),
                  if (!isGuest &&
                      (state.goalId != null ||
                          state.isGeneratingRoadmap ||
                          state.roadmapId != null))
                    ChatMilestoneBadge(
                      goalId: state.goalId,
                      isGeneratingRoadmap: state.isGeneratingRoadmap,
                      roadmapId: state.roadmapId,
                      onExploreJourney: (roadmapId) {
                        context.push(AppRoutes.roadmapDetail(roadmapId));
                      },
                    ),
                  if (!isGuest)
                    ChatComposer(
                      onSend: (text) {
                        context.read<ChatBloc>().add(
                          ChatMessageSubmitted(content: text),
                        );
                        _scrollToBottom();
                      },
                      onCancel: () {
                        context.read<ChatBloc>().add(
                          const ChatCancelRequested(),
                        );
                      },
                      isStreaming: state.isStreaming,
                      isEnabled: state.canSendMessage,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ChatState state) {
    final hasMessages = state.messages.isNotEmpty;

    return AppBar(
      backgroundColor: AppColors.warmIvory,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.cobalt,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ask Learno',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              if (state.selectedCapability != null &&
                  state.status != ChatStatus.guest)
                Text(
                  state.selectedCapability!.title,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ],
      ),
      actions: [
        if (hasMessages && !state.isStreaming)
          IconButton(
            tooltip: 'New Conversation',
            icon: const Icon(
              Icons.restart_alt_rounded,
              color: AppColors.cobalt,
            ),
            onPressed: () {
              context.read<ChatBloc>().add(const ChatResetRequested());
            },
          ),
        const SizedBox(width: AppSpacing.xs),
      ],
    );
  }

  Widget _buildBody(BuildContext context, ChatState state) {
    if (state.status == ChatStatus.guest) {
      return const ChatGuestView();
    }

    if ((state.status == ChatStatus.initial ||
            state.status == ChatStatus.loading) &&
        state.messages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.cobalt),
      );
    }

    if (state.status == ChatStatus.error && state.messages.isEmpty) {
      return Center(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.coral,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Failed to load Learno',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                state.errorMessage ?? 'An unexpected error occurred.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<ChatBloc>().add(
                    const ChatStarted(isAuthenticated: true),
                  );
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cobalt,
                  foregroundColor: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.messages.isEmpty) {
      return ChatWelcomeView(
        onPromptSelected: (prompt) {
          context.read<ChatBloc>().add(ChatMessageSubmitted(content: prompt));
          _scrollToBottom();
        },
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        final isLast = index == state.messages.length - 1;
        final isStreamingActive = isLast && state.isStreaming;

        return ChatBubble(message: message, isStreaming: isStreamingActive);
      },
    );
  }
}
