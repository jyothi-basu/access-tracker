import '../../core/utils/date_time_utils.dart';

/// Verification status values accepted by the backend.
enum VerificationType { present, fixed, notPresent }

extension VerificationTypeValue on VerificationType {
  String get apiValue {
    switch (this) {
      case VerificationType.present:
        return 'present';
      case VerificationType.fixed:
        return 'fixed';
      case VerificationType.notPresent:
        return 'not_present';
    }
  }

  String get label {
    switch (this) {
      case VerificationType.present:
        return 'Still present';
      case VerificationType.fixed:
        return 'Fixed for me';
      case VerificationType.notPresent:
        return 'Not present';
    }
  }

}

VerificationType verificationTypeFromApi(String value) {
  switch (value) {
    case 'fixed':
      return VerificationType.fixed;
    case 'not_present':
      return VerificationType.notPresent;
    default:
      return VerificationType.present;
  }
}

/// Verification returned by the backend.
class VerificationModel {
  final String id;
  final String bugId;
  final String userId;
  final String username;
  final VerificationType verificationType;
  final String appVersion;
  final String? deviceModel;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VerificationModel({
    required this.id,
    required this.bugId,
    required this.userId,
    required this.username,
    required this.verificationType,
    required this.appVersion,
    required this.deviceModel,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VerificationModel.fromJson(Map<String, dynamic> json) {
    return VerificationModel(
      id: _value(json['_id'] ?? json['id']),
      bugId: _value(json['bug_id']),
      userId: _value(json['user_id']),
      username: _value(json['username']),
      verificationType: verificationTypeFromApi(
        _value(json['verification_type']),
      ),
      appVersion: _value(json['app_version']),
      deviceModel: json['device_model']?.toString(),
      createdAt: parseBackendDateTime(_value(json['created_at'])),
      updatedAt: parseBackendDateTime(_value(json['updated_at'])),
    );
  }

  static String _value(dynamic value) => value?.toString() ?? '';
}

/// Verification plus the bug data needed by the profile list.
class MyVerificationItem {
  final VerificationModel verification;
  final String applicationName;
  final String bugTitle;

  const MyVerificationItem({
    required this.verification,
    required this.applicationName,
    required this.bugTitle,
  });
}

/// Request fields shared by create and update verification operations.
class VerificationRequest {
  final VerificationType verificationType;
  final String appVersion;
  final String? deviceModel;

  const VerificationRequest({
    required this.verificationType,
    required this.appVersion,
    this.deviceModel,
  });

  Map<String, dynamic> toJson() {
    return {
      'verification_type': verificationType.apiValue,
      'app_version': appVersion,
      if (deviceModel != null && deviceModel!.isNotEmpty)
        'device_model': deviceModel,
    };
  }
}
