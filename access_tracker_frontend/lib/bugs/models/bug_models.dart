import 'package:flutter/foundation.dart';
import '../../core/utils/date_time_utils.dart';

/// Bug report returned by the AccessTracker API.
class BugModel {
  final String id;
  final String reporterUsername;
  final String applicationId;
  final String applicationName;
  final String platform;
  final String appVersion;
  final String title;
  final String actualBehavior;
  final String expectedBehavior;
  final String screenReader;
  final String severity;
  final String? stepsToReproduce;
  final String? screenReaderVersion;
  final String? deviceModel;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BugModel({
    required this.id,
    required this.reporterUsername,
    required this.applicationId,
    required this.applicationName,
    required this.platform,
    required this.appVersion,
    required this.title,
    required this.actualBehavior,
    required this.expectedBehavior,
    required this.screenReader,
    required this.severity,
    required this.stepsToReproduce,
    required this.screenReaderVersion,
    required this.deviceModel,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BugModel.fromJson(Map<String, dynamic> json) {
    return BugModel(
      id: _stringValue(json['_id'] ?? json['id']),
      reporterUsername: _stringValue(json['reporter_username']),
      applicationId: _stringValue(json['application_id']),
      applicationName: _stringValue(json['application_name']),
      platform: _stringValue(json['platform']),
      appVersion: _stringValue(json['app_version']),
      title: _stringValue(json['title']),
      actualBehavior: _stringValue(json['actual_behavior']),
      expectedBehavior: _stringValue(json['expected_behavior']),
      screenReader: _stringValue(json['screen_reader']),
      severity: _stringValue(json['severity']),
      stepsToReproduce: json['steps_to_reproduce']?.toString(),
      screenReaderVersion: json['screen_reader_version']?.toString(),
      deviceModel: json['device_model']?.toString(),
      createdBy: _stringValue(json['created_by']),
      createdAt: parseBackendDateTime(_stringValue(json['created_at'])),
      updatedAt: parseBackendDateTime(_stringValue(json['updated_at'])),
    );
  }

  static String _stringValue(dynamic value) => value?.toString() ?? '';
}

/// Payload accepted by the create bug endpoint.
class CreateBugRequest {
  final String applicationName;
  final String platform;
  final String appVersion;
  final String title;
  final String severity;
  final String screenReader;
  final String actualBehavior;
  final String expectedBehavior;
  final String? stepsToReproduce;
  final String? deviceModel;

  const CreateBugRequest({
    required this.applicationName,
    required this.platform,
    required this.appVersion,
    required this.title,
    required this.severity,
    required this.screenReader,
    required this.actualBehavior,
    required this.expectedBehavior,
    this.stepsToReproduce,
    this.deviceModel,
  });

  /// Converts the form values to the backend request field names.
  Map<String, dynamic> toJson() {
    return {
      'application_name': applicationName,
      'platform': platform,
      'app_version': appVersion,
      'title': title,
      'severity': severity,
      'screen_reader': screenReader,
      'actual_behavior': actualBehavior,
      'expected_behavior': expectedBehavior,
      if (stepsToReproduce != null && stepsToReproduce!.isNotEmpty)
        'steps_to_reproduce': stepsToReproduce,
      if (deviceModel != null && deviceModel!.isNotEmpty)
        'device_model': deviceModel,
    };
  }
}

/// Fields accepted by the backend bug update endpoint.
class UpdateBugRequest {
  final String? appVersion;
  final String? title;
  final String? severity;
  final String? actualBehavior;
  final String? expectedBehavior;
  final String? stepsToReproduce;

  const UpdateBugRequest({
    this.appVersion,
    this.title,
    this.severity,
    this.actualBehavior,
    this.expectedBehavior,
    this.stepsToReproduce,
  });

  Map<String, dynamic> toJson() {
    return {
      if (appVersion != null) 'app_version': appVersion,
      if (title != null) 'title': title,
      if (severity != null) 'severity': severity,
      if (actualBehavior != null) 'actual_behavior': actualBehavior,
      if (expectedBehavior != null) 'expected_behavior': expectedBehavior,
      if (stepsToReproduce != null) 'steps_to_reproduce': stepsToReproduce,
    };
  }
}

/// Counts returned by the bug verification summary endpoint.
class VerificationSummary {
  final int present;
  final int fixed;
  final int notPresent;
  final int total;

  const VerificationSummary({
    required this.present,
    required this.fixed,
    required this.notPresent,
    required this.total,
  });

  factory VerificationSummary.fromJson(Map<String, dynamic> json) {
    int count(String key) => (json[key] as num?)?.toInt() ?? 0;

    return VerificationSummary(
      present: count('present'),
      fixed: count('fixed'),
      notPresent: count('not_present'),
      total: count('total'),
    );
  }
}

/// Sort choices supported by the bug feed.
enum BugSortOrder { newest, oldest }

/// Active server-side filters and client-side sort order for the feed.
@immutable
class BugFeedFilters {
  final String? applicationId;
  final String? applicationName;
  final String? platform;
  final String? screenReader;
  final String? severity;
  final BugSortOrder sortOrder;

  const BugFeedFilters({
    this.applicationId,
    this.applicationName,
    this.platform,
    this.screenReader,
    this.severity,
    this.sortOrder = BugSortOrder.newest,
  });

  BugFeedFilters copyWith({
    String? applicationId,
    String? applicationName,
    String? platform,
    String? screenReader,
    String? severity,
    BugSortOrder? sortOrder,
    bool clearPlatform = false,
    bool clearApplicationId = false,
    bool clearApplicationName = false,
    bool clearScreenReader = false,
    bool clearSeverity = false,
  }) {
    return BugFeedFilters(
      applicationId: clearApplicationId ? null : (applicationId ?? this.applicationId),
      applicationName: clearApplicationName
          ? null
          : (applicationName ?? this.applicationName),
      platform: clearPlatform ? null : (platform ?? this.platform),
      screenReader: clearScreenReader ? null : (screenReader ?? this.screenReader),
      severity: clearSeverity ? null : (severity ?? this.severity),
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
