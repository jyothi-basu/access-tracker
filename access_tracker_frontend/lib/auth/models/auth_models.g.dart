// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
    };

VerifyRegistrationRequest _$VerifyRegistrationRequestFromJson(
        Map<String, dynamic> json) =>
    VerifyRegistrationRequest(
      email: json['email'] as String,
      otp: json['otp'] as String,
    );

Map<String, dynamic> _$VerifyRegistrationRequestToJson(
        VerifyRegistrationRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'otp': instance.otp,
    };

OtpRequest _$OtpRequestFromJson(Map<String, dynamic> json) => OtpRequest(
      email: json['email'] as String,
    );

Map<String, dynamic> _$OtpRequestToJson(OtpRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
    };

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
    };

TokenPairResponse _$TokenPairResponseFromJson(Map<String, dynamic> json) =>
    TokenPairResponse(
      access_token: json['access_token'] as String,
      refresh_token: json['refresh_token'] as String,
      token_type: json['token_type'] as String,
      access_token_expires_in: (json['access_token_expires_in'] as num).toInt(),
      refresh_token_expires_in: (json['refresh_token_expires_in'] as num).toInt(),
    );

Map<String, dynamic> _$TokenPairResponseToJson(TokenPairResponse instance) =>
    <String, dynamic>{
      'access_token': instance.access_token,
      'refresh_token': instance.refresh_token,
      'token_type': instance.token_type,
      'access_token_expires_in': instance.access_token_expires_in,
      'refresh_token_expires_in': instance.refresh_token_expires_in,
    };

UserResponse _$UserResponseFromJson(Map<String, dynamic> json) => UserResponse(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      is_email_verified: json['is_email_verified'] as bool,
      created_at: json['created_at'] as String,
      updated_at: json['updated_at'] as String,
    );

Map<String, dynamic> _$UserResponseToJson(UserResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
      'is_email_verified': instance.is_email_verified,
      'created_at': instance.created_at,
      'updated_at': instance.updated_at,
    };

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
      user: UserResponse.fromJson(json['user'] as Map<String, dynamic>),
      tokens: TokenPairResponse.fromJson(json['tokens'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'user': instance.user,
      'tokens': instance.tokens,
    };

RefreshRequest _$RefreshRequestFromJson(Map<String, dynamic> json) =>
    RefreshRequest(
      refresh_token: json['refresh_token'] as String,
    );

Map<String, dynamic> _$RefreshRequestToJson(RefreshRequest instance) =>
    <String, dynamic>{
      'refresh_token': instance.refresh_token,
    };

LogoutRequest _$LogoutRequestFromJson(Map<String, dynamic> json) =>
    LogoutRequest(
      refresh_token: json['refresh_token'] as String,
    );

Map<String, dynamic> _$LogoutRequestToJson(LogoutRequest instance) =>
    <String, dynamic>{
      'refresh_token': instance.refresh_token,
    };

MessageResponse _$MessageResponseFromJson(Map<String, dynamic> json) =>
    MessageResponse(
      detail: json['detail'] as String,
    );

Map<String, dynamic> _$MessageResponseToJson(MessageResponse instance) =>
    <String, dynamic>{
      'detail': instance.detail,
    };

ResetPasswordRequest _$ResetPasswordRequestFromJson(Map<String, dynamic> json) =>
    ResetPasswordRequest(
      reset_token: json['reset_token'] as String,
      new_password: json['new_password'] as String,
    );

Map<String, dynamic> _$ResetPasswordRequestToJson(ResetPasswordRequest instance) =>
    <String, dynamic>{
      'reset_token': instance.reset_token,
      'new_password': instance.new_password,
    };

ResetTokenResponse _$ResetTokenResponseFromJson(Map<String, dynamic> json) =>
    ResetTokenResponse(
      reset_token: json['reset_token'] as String,
    );

Map<String, dynamic> _$ResetTokenResponseToJson(ResetTokenResponse instance) =>
    <String, dynamic>{
      'reset_token': instance.reset_token,
    };
