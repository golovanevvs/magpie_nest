const kJournalPruneThrottle = Duration(hours: 6);
const kDeviceStaleAfter = Duration(days: 90);
const kJournalMinAge = Duration(days: 30);

class SyncDeviceInfo {
  final String deviceId;
  final String platform;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String lastPulledJournalFile;

  const SyncDeviceInfo({
    required this.deviceId,
    required this.platform,
    required this.createdAt,
    required this.updatedAt,
    required this.lastPulledJournalFile,
  });

  factory SyncDeviceInfo.fromJson(Map<String, Object?> json) => SyncDeviceInfo(
    deviceId: json['deviceId']! as String,
    platform: json['platform'] as String? ?? '',
    createdAt: DateTime.parse(json['createdAt']! as String),
    updatedAt: DateTime.parse(json['updatedAt']! as String),
    lastPulledJournalFile: json['lastPulledJournalFile'] as String? ?? '',
  );

  Map<String, Object?> toJson() => {
    'deviceId': deviceId,
    'platform': platform,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'lastPulledJournalFile': lastPulledJournalFile,
  };
}
