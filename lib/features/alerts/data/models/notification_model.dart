class NotificationModel {
  final String uuid;
  final String type;
  final String source;
  final String title;
  final String body;
  final DateTime? readAt;
  final DateTime createdAt;

  bool get isRead => readAt != null;

  NotificationModel({
    required this.uuid,
    required this.type,
    required this.source,
    required this.title,
    required this.body,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      uuid: json['uuid'] ?? '',
      type: json['type'] ?? '',
      source: json['source'] ?? 'SYSTEM',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      readAt: json['read_at'] != null
          ? DateTime.tryParse(json['read_at'])
          : null,
      createdAt:
          DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  NotificationModel copyWith({DateTime? readAt}) {
    return NotificationModel(
      uuid: uuid,
      type: type,
      source: source,
      title: title,
      body: body,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
    );
  }
}
