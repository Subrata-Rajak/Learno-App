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
    });
  });
}
