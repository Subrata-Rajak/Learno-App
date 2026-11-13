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
}

/// Resets all registered dependencies, primarily used across test suites.
Future<void> resetDependencies() async {
  await getIt.reset();
}
