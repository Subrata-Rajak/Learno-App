import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learno/core/config/app_config.dart';
import 'package:learno/core/di/injection.dart';
import 'package:learno/core/network/api_client.dart';
import 'package:learno/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:learno/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:learno/features/auth/domain/repositories/auth_repository.dart';
import 'package:learno/features/auth/domain/usecases/login.dart';
import 'package:learno/features/auth/domain/usecases/logout.dart';
import 'package:learno/features/auth/domain/usecases/register.dart';
import 'package:learno/features/auth/domain/usecases/restore_session.dart';
import 'package:learno/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:learno/features/home/data/datasources/home_local_datasource.dart';
import 'package:learno/features/home/domain/repositories/home_repository.dart';
import 'package:learno/features/home/domain/usecases/get_home_journeys.dart';
import 'package:learno/features/home/presentation/bloc/home_bloc.dart';
import 'package:learno/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:learno/features/chat/domain/repositories/chat_repository.dart';
import 'package:learno/features/chat/domain/usecases/create_conversation.dart';
import 'package:learno/features/chat/domain/usecases/get_capabilities.dart';
import 'package:learno/features/chat/domain/usecases/get_conversation.dart';
import 'package:learno/features/chat/domain/usecases/get_conversation_messages.dart';
import 'package:learno/features/chat/domain/usecases/get_conversations.dart';
import 'package:learno/features/chat/domain/usecases/send_chat_message_stream.dart';
import 'package:learno/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:learno/features/roadmap/data/datasources/roadmap_remote_data_source.dart';
import 'package:learno/features/roadmap/domain/repositories/roadmap_repository.dart';
import 'package:learno/features/roadmap/domain/usecases/complete_topic.dart';
import 'package:learno/features/roadmap/domain/usecases/get_active_learning_goals.dart';
import 'package:learno/features/roadmap/domain/usecases/get_roadmap.dart';
import 'package:learno/features/roadmap/domain/usecases/get_roadmap_by_goal.dart';
import 'package:learno/features/roadmap/domain/usecases/get_roadmap_progress.dart';
import 'package:learno/features/roadmap/domain/usecases/get_topic_resources.dart';
import 'package:learno/features/roadmap/presentation/bloc/roadmap_bloc.dart';

void main() {
  group('Dependency Injection', () {
    setUp(() async {
      await resetDependencies();
    });

    tearDown(() async {
      await resetDependencies();
    });

    test(
      'registers all required dependencies without circular references',
      () async {
        await configureDependencies(
          config: const AppConfig(
            environment: AppEnvironment.development,
            apiBaseUrl: 'http://localhost:3000',
          ),
        );

        // Verify core & storage
        expect(getIt.isRegistered<AppConfig>(), isTrue);
        expect(getIt.isRegistered<FlutterSecureStorage>(), isTrue);
        expect(getIt.isRegistered<ApiClient>(), isTrue);
        expect(getIt.isRegistered<Dio>(), isTrue);

        // Verify Auth dependencies
        expect(getIt.isRegistered<AuthLocalDataSource>(), isTrue);
        expect(getIt.isRegistered<AuthRemoteDataSource>(), isTrue);
        expect(getIt.isRegistered<AuthRepository>(), isTrue);
        expect(getIt.isRegistered<Login>(), isTrue);
        expect(getIt.isRegistered<Register>(), isTrue);
        expect(getIt.isRegistered<RestoreSession>(), isTrue);
        expect(getIt.isRegistered<Logout>(), isTrue);
        expect(getIt.isRegistered<AuthBloc>(), isTrue);

        // Verify Home dependencies
        expect(getIt.isRegistered<HomeLocalDataSource>(), isTrue);
        expect(getIt.isRegistered<HomeRepository>(), isTrue);
        expect(getIt.isRegistered<GetHomeJourneys>(), isTrue);
        expect(getIt.isRegistered<HomeBloc>(), isTrue);

        // Verify Chat dependencies
        expect(getIt.isRegistered<ChatRemoteDataSource>(), isTrue);
        expect(getIt.isRegistered<ChatRepository>(), isTrue);
        expect(getIt.isRegistered<GetCapabilities>(), isTrue);
        expect(getIt.isRegistered<CreateConversation>(), isTrue);
        expect(getIt.isRegistered<GetConversation>(), isTrue);
        expect(getIt.isRegistered<GetConversations>(), isTrue);
        expect(getIt.isRegistered<GetConversationMessages>(), isTrue);
        expect(getIt.isRegistered<SendChatMessageStream>(), isTrue);
        expect(getIt.isRegistered<ChatBloc>(), isTrue);

        // Verify Roadmap dependencies
        expect(getIt.isRegistered<RoadmapRemoteDataSource>(), isTrue);
        expect(getIt.isRegistered<RoadmapRepository>(), isTrue);
        expect(getIt.isRegistered<GetRoadmap>(), isTrue);
        expect(getIt.isRegistered<GetRoadmapByGoal>(), isTrue);
        expect(getIt.isRegistered<GetRoadmapProgress>(), isTrue);
        expect(getIt.isRegistered<CompleteTopic>(), isTrue);
        expect(getIt.isRegistered<GetTopicResources>(), isTrue);
        expect(getIt.isRegistered<GetActiveLearningGoals>(), isTrue);
        expect(getIt.isRegistered<RoadmapBloc>(), isTrue);

        // Verify factories yield distinct instances
        final authBloc1 = getIt<AuthBloc>();
        final authBloc2 = getIt<AuthBloc>();
        expect(identical(authBloc1, authBloc2), isFalse);
        authBloc1.close();
        authBloc2.close();

        final homeBloc1 = getIt<HomeBloc>();
        final homeBloc2 = getIt<HomeBloc>();
        expect(identical(homeBloc1, homeBloc2), isFalse);
        homeBloc1.close();
        homeBloc2.close();

        final chatBloc1 = getIt<ChatBloc>();
        final chatBloc2 = getIt<ChatBloc>();
        expect(identical(chatBloc1, chatBloc2), isFalse);
        chatBloc1.close();
        chatBloc2.close();

        final roadmapBloc1 = getIt<RoadmapBloc>();
        final roadmapBloc2 = getIt<RoadmapBloc>();
        expect(identical(roadmapBloc1, roadmapBloc2), isFalse);
        roadmapBloc1.close();
        roadmapBloc2.close();
      },
    );

    test('resetDependencies clears registrations cleanly', () async {
      await configureDependencies();
      expect(getIt.isRegistered<AppConfig>(), isTrue);
      expect(getIt.isRegistered<AuthBloc>(), isTrue);

      await resetDependencies();
      expect(getIt.isRegistered<AppConfig>(), isFalse);
      expect(getIt.isRegistered<AuthBloc>(), isFalse);
      expect(getIt.isRegistered<HomeBloc>(), isFalse);
      expect(getIt.isRegistered<ChatBloc>(), isFalse);
      expect(getIt.isRegistered<RoadmapBloc>(), isFalse);
    });
  });
}
