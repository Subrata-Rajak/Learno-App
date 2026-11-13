import 'package:equatable/equatable.dart';

/// DTO representing the response from `POST /api/v1/auth/refresh`.
class TokenRefreshResponseModel extends Equatable {
  const TokenRefreshResponseModel({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory TokenRefreshResponseModel.fromJson(Map<String, dynamic> json) {
    return TokenRefreshResponseModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }

  @override
  List<Object?> get props => [accessToken, refreshToken];
}
