import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learno/features/auth/data/datasources/auth_local_datasource.dart';

class FakeFlutterSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _storage[key] = value;
    } else {
      _storage.remove(key);
    }
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _storage[key];
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.remove(key);
  }
}

void main() {
  late FakeFlutterSecureStorage fakeStorage;
  late AuthLocalDataSourceImpl dataSource;

  setUp(() {
    fakeStorage = FakeFlutterSecureStorage();
    dataSource = AuthLocalDataSourceImpl(secureStorage: fakeStorage);
  });

  group('AuthLocalDataSource', () {
    test('returns null when tokens have not been saved', () async {
      expect(await dataSource.getAccessToken(), isNull);
      expect(await dataSource.getRefreshToken(), isNull);
    });

    test('saves and reads access and refresh tokens correctly', () async {
      await dataSource.saveTokens(
        accessToken: 'sample_access_jwt',
        refreshToken: 'sample_refresh_token',
      );

      expect(await dataSource.getAccessToken(), equals('sample_access_jwt'));
      expect(
        await dataSource.getRefreshToken(),
        equals('sample_refresh_token'),
      );
    });

    test('clears stored tokens cleanly', () async {
      await dataSource.saveTokens(
        accessToken: 'sample_access_jwt',
        refreshToken: 'sample_refresh_token',
      );

      await dataSource.clearTokens();

      expect(await dataSource.getAccessToken(), isNull);
      expect(await dataSource.getRefreshToken(), isNull);
    });
  });
}
