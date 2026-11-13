import 'package:learno/core/network/api_client.dart';
import 'package:learno/core/network/api_endpoints.dart';
import 'package:learno/core/network/errors/app_exception.dart';
import 'package:learno/core/network/models/api_response.dart';
import 'package:learno/features/auth/data/models/auth_user_model.dart';
import 'package:learno/features/auth/data/models/login_response_model.dart';
import 'package:learno/features/auth/data/models/token_refresh_response_model.dart';

/// Contract for remote authentication API calls.
abstract interface class AuthRemoteDataSource {
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  });

  Future<AuthUserModel> register({
    required String email,
    required String password,
    String? name,
  });

  Future<TokenRefreshResponseModel> refresh({required String refreshToken});

  Future<void> logout({required String refreshToken});

  Future<AuthUserModel> getMe();
}

/// Implementation of [AuthRemoteDataSource] consuming the Learno backend API.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.authLogin,
      data: {'email': email, 'password': password},
    );

    final envelope = ApiResponse<LoginResponseModel>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => LoginResponseModel.fromJson(json as Map<String, dynamic>),
    );

    if (!envelope.success || envelope.data == null) {
      throw ServerException(
        message: envelope.message.isNotEmpty
            ? envelope.message
            : 'Login failed on server.',
        errorCode: envelope.error?.code,
        details: envelope.error?.details,
      );
    }

    return envelope.data!;
  }

  @override
  Future<AuthUserModel> register({
    required String email,
    required String password,
    String? name,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.authRegister,
      data: {
        'email': email,
        'password': password,
        if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
      },
    );

    final envelope = ApiResponse<AuthUserModel>.fromJson(
      response.data as Map<String, dynamic>,
      (json) {
        final map = json as Map<String, dynamic>;
        // Backend returns `{ user: { ... } }` in data
        final userMap = map['user'] as Map<String, dynamic>? ?? map;
        return AuthUserModel.fromJson(userMap);
      },
    );

    if (!envelope.success || envelope.data == null) {
      throw ServerException(
        message: envelope.message.isNotEmpty
            ? envelope.message
            : 'Registration failed on server.',
        errorCode: envelope.error?.code,
        details: envelope.error?.details,
      );
    }

    return envelope.data!;
  }

  @override
  Future<TokenRefreshResponseModel> refresh({
    required String refreshToken,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.authRefresh,
      data: {'refreshToken': refreshToken},
    );

    final envelope = ApiResponse<TokenRefreshResponseModel>.fromJson(
      response.data as Map<String, dynamic>,
      (json) =>
          TokenRefreshResponseModel.fromJson(json as Map<String, dynamic>),
    );

    if (!envelope.success || envelope.data == null) {
      throw UnauthorizedException(
        message: envelope.message.isNotEmpty
            ? envelope.message
            : 'Token refresh failed.',
        errorCode: envelope.error?.code ?? 'INVALID_REFRESH_TOKEN',
        details: envelope.error?.details,
      );
    }

    return envelope.data!;
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    final response = await apiClient.post(
      ApiEndpoints.authLogout,
      data: {'refreshToken': refreshToken},
    );

    final envelope = ApiResponse<dynamic>.fromJson(
      response.data as Map<String, dynamic>,
    );

    if (!envelope.success) {
      throw ServerException(
        message: envelope.message.isNotEmpty
            ? envelope.message
            : 'Logout failed on server.',
        errorCode: envelope.error?.code,
      );
    }
  }

  @override
  Future<AuthUserModel> getMe() async {
    final response = await apiClient.get(ApiEndpoints.authMe);

    final envelope = ApiResponse<AuthUserModel>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => AuthUserModel.fromJson(json as Map<String, dynamic>),
    );

    if (!envelope.success || envelope.data == null) {
      throw UnauthorizedException(
        message: envelope.message.isNotEmpty
            ? envelope.message
            : 'Unable to retrieve authenticated user.',
        errorCode: envelope.error?.code ?? 'USER_NOT_FOUND',
      );
    }

    return envelope.data!;
  }
}
