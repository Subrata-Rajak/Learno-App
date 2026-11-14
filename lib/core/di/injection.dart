import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:learno/core/config/app_config.dart';
import 'package:learno/core/network/api_client.dart';
import 'package:learno/core/network/interceptors/auth_header_interceptor.dart';
import 'package:learno/core/network/interceptors/token_refresh_interceptor.dart';
import 'package:learno/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:learno/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:learno/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:learno/features/auth/domain/repositories/auth_repository.dart';
import 'package:learno/features/auth/domain/usecases/login.dart';
import 'package:learno/features/auth/domain/usecases/logout.dart';
import 'package:learno/features/auth/domain/usecases/register.dart';
import 'package:learno/features/auth/domain/usecases/restore_session.dart';
import 'package:learno/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:learno/features/home/data/datasources/home_local_datasource.dart';
import 'package:learno/features/home/data/repositories/home_repository_impl.dart';
import 'package:learno/features/home/domain/repositories/home_repository.dart';
import 'package:learno/features/home/domain/usecases/get_home_journeys.dart';
import 'package:learno/features/home/presentation/bloc/home_bloc.dart';
import 'package:learno/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:learno/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:learno/features/chat/domain/repositories/chat_repository.dart';
import 'package:learno/features/chat/domain/usecases/create_conversation.dart';
import 'package:learno/features/chat/domain/usecases/get_capabilities.dart';
import 'package:learno/features/chat/domain/usecases/get_conversation.dart';
import 'package:learno/features/chat/domain/usecases/get_conversation_messages.dart';
import 'package:learno/features/chat/domain/usecases/get_conversations.dart';
import 'package:learno/features/chat/domain/usecases/send_chat_message_stream.dart';
import 'package:learno/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:learno/features/roadmap/data/datasources/roadmap_remote_data_source.dart';
import 'package:learno/features/roadmap/data/repositories/roadmap_repository_impl.dart';
import 'package:learno/features/roadmap/domain/repositories/roadmap_repository.dart';
import 'package:learno/features/roadmap/domain/usecases/complete_topic.dart';
import 'package:learno/features/roadmap/domain/usecases/get_active_learning_goals.dart';
import 'package:learno/features/roadmap/domain/usecases/get_roadmap.dart';
import 'package:learno/features/roadmap/domain/usecases/get_roadmap_by_goal.dart';
import 'package:learno/features/roadmap/domain/usecases/get_roadmap_progress.dart';
import 'package:learno/features/roadmap/domain/usecases/get_topic_resources.dart';
import 'package:learno/features/roadmap/presentation/bloc/roadmap_bloc.dart';

/// Global service locator instance.
final GetIt getIt = GetIt.instance;

/// Centralized dependency injection initializer for Learno.
///
/// Registers core configuration, network infrastructure, data sources,
/// repositories, use cases, and BLoC factories using strict lifetime semantics.
Future<void> configureDependencies({
  AppConfig? config,
  FlutterSecureStorage? secureStorage,
}) async {
  // 1. Core Configuration (Singleton)
  if (!getIt.isRegistered<AppConfig>()) {
    final appConfig = config ?? AppConfig.fromEnvironment();
    getIt.registerSingleton<AppConfig>(appConfig);
  }

  // 2. Secure Storage & Local Auth Data Source (Singletons)
  if (!getIt.isRegistered<FlutterSecureStorage>()) {
    getIt.registerLazySingleton<FlutterSecureStorage>(
      () =>
          secureStorage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(resetOnError: true),
          ),
    );
  }

  if (!getIt.isRegistered<AuthLocalDataSource>()) {
    getIt.registerLazySingleton<AuthLocalDataSource>(
      () =>
          AuthLocalDataSourceImpl(secureStorage: getIt<FlutterSecureStorage>()),
    );
  }

  // 3. Network Infrastructure (Lazy Singletons)
  if (!getIt.isRegistered<ApiClient>()) {
    getIt.registerLazySingleton<ApiClient>(() {
      final client = ApiClient(
        config: getIt<AppConfig>(),
        authInterceptor: AuthHeaderInterceptor(
          tokenProvider: () => getIt<AuthLocalDataSource>().getAccessToken(),
        ),
      );

      client.addInterceptor(
        TokenRefreshInterceptor(
          onRefresh: () => getIt<AuthRepository>().refreshSession(),
          tokenGetter: () => getIt<AuthLocalDataSource>().getAccessToken(),
          dio: client.dio,
        ),
      );

      return client;
    });
  }

  if (!getIt.isRegistered<Dio>()) {
    getIt.registerLazySingleton<Dio>(() => getIt<ApiClient>().dio);
  }

  // 4. Auth Feature - Data Layer (Lazy Singletons)
  if (!getIt.isRegistered<AuthRemoteDataSource>()) {
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
    );
  }

  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: getIt<AuthRemoteDataSource>(),
        localDataSource: getIt<AuthLocalDataSource>(),
      ),
    );
  }

  // 5. Auth Feature - Domain Layer (Lazy Singletons)
  if (!getIt.isRegistered<Login>()) {
    getIt.registerLazySingleton<Login>(() => Login(getIt<AuthRepository>()));
  }

  if (!getIt.isRegistered<Register>()) {
    getIt.registerLazySingleton<Register>(
      () => Register(getIt<AuthRepository>()),
    );
  }

  if (!getIt.isRegistered<RestoreSession>()) {
    getIt.registerLazySingleton<RestoreSession>(
      () => RestoreSession(getIt<AuthRepository>()),
    );
  }

  if (!getIt.isRegistered<Logout>()) {
    getIt.registerLazySingleton<Logout>(() => Logout(getIt<AuthRepository>()));
  }

  // 6. Auth Feature - Presentation Layer (Factory)
  if (!getIt.isRegistered<AuthBloc>()) {
    getIt.registerFactory<AuthBloc>(
      () => AuthBloc(
        login: getIt<Login>(),
        register: getIt<Register>(),
        restoreSession: getIt<RestoreSession>(),
        logout: getIt<Logout>(),
      ),
    );
  }

  // 7. Home Feature - Data Layer (Lazy Singletons)
  if (!getIt.isRegistered<HomeLocalDataSource>()) {
    getIt.registerLazySingleton<HomeLocalDataSource>(
      () => const HomeMockDataSource(),
    );
  }

  if (!getIt.isRegistered<HomeRepository>()) {
    getIt.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(dataSource: getIt<HomeLocalDataSource>()),
    );
  }

  // 8. Home Feature - Domain Layer (Lazy Singleton)
  if (!getIt.isRegistered<GetHomeJourneys>()) {
    getIt.registerLazySingleton<GetHomeJourneys>(
      () => GetHomeJourneys(getIt<HomeRepository>()),
    );
  }

  // 9. Home Feature - Presentation Layer (Factory)
  if (!getIt.isRegistered<HomeBloc>()) {
    getIt.registerFactory<HomeBloc>(
      () => HomeBloc(getHomeJourneys: getIt<GetHomeJourneys>()),
    );
  }

  // 10. Chat Feature - Data Layer (Lazy Singletons)
  if (!getIt.isRegistered<ChatRemoteDataSource>()) {
    getIt.registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
    );
  }

  if (!getIt.isRegistered<ChatRepository>()) {
    getIt.registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(remoteDataSource: getIt<ChatRemoteDataSource>()),
    );
  }

  // 11. Chat Feature - Domain Layer (Lazy Singletons)
  if (!getIt.isRegistered<GetCapabilities>()) {
    getIt.registerLazySingleton<GetCapabilities>(
      () => GetCapabilities(getIt<ChatRepository>()),
    );
  }

  if (!getIt.isRegistered<CreateConversation>()) {
    getIt.registerLazySingleton<CreateConversation>(
      () => CreateConversation(getIt<ChatRepository>()),
    );
  }

  if (!getIt.isRegistered<GetConversation>()) {
    getIt.registerLazySingleton<GetConversation>(
      () => GetConversation(getIt<ChatRepository>()),
    );
  }

  if (!getIt.isRegistered<GetConversations>()) {
    getIt.registerLazySingleton<GetConversations>(
      () => GetConversations(getIt<ChatRepository>()),
    );
  }

  if (!getIt.isRegistered<GetConversationMessages>()) {
    getIt.registerLazySingleton<GetConversationMessages>(
      () => GetConversationMessages(getIt<ChatRepository>()),
    );
  }

  if (!getIt.isRegistered<SendChatMessageStream>()) {
    getIt.registerLazySingleton<SendChatMessageStream>(
      () => SendChatMessageStream(getIt<ChatRepository>()),
    );
  }

  // 12. Chat Feature - Presentation Layer (Factory)
  if (!getIt.isRegistered<ChatBloc>()) {
    getIt.registerFactory<ChatBloc>(
      () => ChatBloc(
        getCapabilities: getIt<GetCapabilities>(),
        createConversation: getIt<CreateConversation>(),
        getConversation: getIt<GetConversation>(),
        getConversations: getIt<GetConversations>(),
        getConversationMessages: getIt<GetConversationMessages>(),
        sendChatMessageStream: getIt<SendChatMessageStream>(),
      ),
    );
  }

  // 13. Roadmap Feature - Data Layer (Lazy Singletons)
  if (!getIt.isRegistered<RoadmapRemoteDataSource>()) {
    getIt.registerLazySingleton<RoadmapRemoteDataSource>(
      () => RoadmapRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
    );
  }

  if (!getIt.isRegistered<RoadmapRepository>()) {
    getIt.registerLazySingleton<RoadmapRepository>(
      () => RoadmapRepositoryImpl(
        remoteDataSource: getIt<RoadmapRemoteDataSource>(),
      ),
    );
  }

  // 14. Roadmap Feature - Domain Layer (Lazy Singletons)
  if (!getIt.isRegistered<GetRoadmap>()) {
    getIt.registerLazySingleton<GetRoadmap>(
      () => GetRoadmap(getIt<RoadmapRepository>()),
    );
  }

  if (!getIt.isRegistered<GetRoadmapByGoal>()) {
    getIt.registerLazySingleton<GetRoadmapByGoal>(
      () => GetRoadmapByGoal(getIt<RoadmapRepository>()),
    );
  }

  if (!getIt.isRegistered<GetRoadmapProgress>()) {
    getIt.registerLazySingleton<GetRoadmapProgress>(
      () => GetRoadmapProgress(getIt<RoadmapRepository>()),
    );
  }

  if (!getIt.isRegistered<CompleteTopic>()) {
    getIt.registerLazySingleton<CompleteTopic>(
      () => CompleteTopic(getIt<RoadmapRepository>()),
    );
  }

  if (!getIt.isRegistered<GetTopicResources>()) {
    getIt.registerLazySingleton<GetTopicResources>(
      () => GetTopicResources(getIt<RoadmapRepository>()),
    );
  }

  if (!getIt.isRegistered<GetActiveLearningGoals>()) {
    getIt.registerLazySingleton<GetActiveLearningGoals>(
      () => GetActiveLearningGoals(getIt<RoadmapRepository>()),
    );
  }

  // 15. Roadmap Feature - Presentation Layer (Factory)
  if (!getIt.isRegistered<RoadmapBloc>()) {
    getIt.registerFactory<RoadmapBloc>(
      () => RoadmapBloc(
        getRoadmap: getIt<GetRoadmap>(),
        getRoadmapByGoal: getIt<GetRoadmapByGoal>(),
        getActiveLearningGoals: getIt<GetActiveLearningGoals>(),
      ),
    );
  }
}

/// Resets all registered dependencies, primarily used across test suites.
Future<void> resetDependencies() async {
  await getIt.reset();
}
