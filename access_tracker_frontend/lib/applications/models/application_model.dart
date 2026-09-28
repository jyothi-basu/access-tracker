/// Application returned by the AccessTracker applications endpoint.
class ApplicationModel {
  final String id;
  final String displayName;
  final String? platform;
  final bool isTemporary;

  const ApplicationModel({
    required this.id,
    required this.displayName,
    required this.platform,
    this.isTemporary = false,
  });

  /// Creates the temporary selection used when no existing result matches.
  const ApplicationModel.temporary({required String displayName})
      : id = '',
        displayName = displayName,
        platform = null,
        isTemporary = true;

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? '',
      platform: json['platform']?.toString(),
    );
  }
}
