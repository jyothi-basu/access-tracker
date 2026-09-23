import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

@JsonSerializable()
class RegisterRequest {
  final String name;
  final String email;
  final String password;

  RegisterRequest({required this.name, required this.email, required this.password});

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class VerifyRegistrationRequest {
  final String email;
  final String otp;

  VerifyRegistrationRequest({required this.email, required this.otp});

  factory VerifyRegistrationRequest.fromJson(Map<String, dynamic> json) => _$VerifyRegistrationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$VerifyRegistrationRequestToJson(this);
}

@JsonSerializable()
class OtpRequest {
  final String email;

  OtpRequest({required this.email});

  factory OtpRequest.fromJson(Map<String, dynamic> json) => _$OtpRequestFromJson(json);
  Map<String, dynamic> toJson() => _$OtpRequestToJson(this);
}

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class TokenPairResponse {
  final String access_token;
  final String refresh_token;
  final String token_type;
  final int access_token_expires_in;
  final int refresh_token_expires_in;

  TokenPairResponse({
    required this.access_token,
    required this.refresh_token,
    required this.token_type,
    required this.access_token_expires_in,
    required this.refresh_token_expires_in,
  });

  factory TokenPairResponse.fromJson(Map<String, dynamic> json) => _$TokenPairResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TokenPairResponseToJson(this);
}

@JsonSerializable()
class UserResponse {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool is_email_verified;
  final String created_at;
  final String updated_at;

  UserResponse({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.is_email_verified,
    required this.created_at,
    required this.updated_at,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => _$UserResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserResponseToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final UserResponse user;
  final TokenPairResponse tokens;

  AuthResponse({required this.user, required this.tokens});

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable()
class RefreshRequest {
  final String refresh_token;

  RefreshRequest({required this.refresh_token});

  factory RefreshRequest.fromJson(Map<String, dynamic> json) => _$RefreshRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RefreshRequestToJson(this);
}

@JsonSerializable()
class LogoutRequest {
  final String refresh_token;

  LogoutRequest({required this.refresh_token});

  factory LogoutRequest.fromJson(Map<String, dynamic> json) => _$LogoutRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LogoutRequestToJson(this);
}

@JsonSerializable()
class MessageResponse {
  final String detail;

  MessageResponse({required this.detail});

  factory MessageResponse.fromJson(Map<String, dynamic> json) => _$MessageResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MessageResponseToJson(this);
}

@JsonSerializable()
class ResetPasswordRequest {
  final String reset_token;
  final String new_password;

  ResetPasswordRequest({required this.reset_token, required this.new_password});

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) => _$ResetPasswordRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ResetPasswordRequestToJson(this);
}

@JsonSerializable()
class ResetTokenResponse {
  final String reset_token;

  ResetTokenResponse({required this.reset_token});

  factory ResetTokenResponse.fromJson(Map<String, dynamic> json) => _$ResetTokenResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ResetTokenResponseToJson(this);
}
