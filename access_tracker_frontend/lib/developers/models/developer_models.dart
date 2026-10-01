import '../../core/utils/date_time_utils.dart';

/// Approved application summary returned for a developer.
class DeveloperApplicationSummary {
  final String applicationId;
  final String applicationName;
  final String platform;
  final int bugCount;

  const DeveloperApplicationSummary({
    required this.applicationId,
    required this.applicationName,
    required this.platform,
    required this.bugCount,
  });

  factory DeveloperApplicationSummary.fromJson(Map<String, dynamic> json) {
    return DeveloperApplicationSummary(
      applicationId: _value(json['application_id']),
      applicationName: _value(json['application_name']),
      platform: _value(json['platform']),
      bugCount: (json['bug_count'] as num?)?.toInt() ?? 0,
    );
  }

  static String _value(dynamic value) => value?.toString() ?? '';
}

/// Developer response returned by the Developers API.
class DeveloperResponse {
  final String id;
  final String bugId;
  final String applicationId;
  final String developerId;
  final String developerUsername;
  final String response;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DeveloperResponse({
    required this.id,
    required this.bugId,
    required this.applicationId,
    required this.developerId,
    required this.developerUsername,
    required this.response,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeveloperResponse.fromJson(Map<String, dynamic> json) {
    return DeveloperResponse(
      id: _value(json['_id'] ?? json['id']),
      bugId: _value(json['bug_id']),
      applicationId: _value(json['application_id']),
      developerId: _value(json['developer_id']),
      developerUsername: _value(json['developer_username']),
      response: _value(json['response']),
      createdAt: parseBackendDateTime(_value(json['created_at'])),
      updatedAt: parseBackendDateTime(_value(json['updated_at'])),
    );
  }

  static String _value(dynamic value) => value?.toString() ?? '';
}

/// Request body for creating or updating a developer response.
class DeveloperResponseRequest {
  final String response;

  const DeveloperResponseRequest({required this.response});

  Map<String, dynamic> toJson() => {'response': response};
}
