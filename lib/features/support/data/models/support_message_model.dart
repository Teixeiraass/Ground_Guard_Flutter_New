class SupportMessageModel {
  final String uuid;
  final String sender;
  final String body;
  final DateTime createdAt;
  final bool pending;
  final bool failed;

  SupportMessageModel({
    required this.uuid,
    required this.sender,
    required this.body,
    required this.createdAt,
    this.pending = false,
    this.failed = false,
  });

  bool get isFromUser => sender == 'USER';

  factory SupportMessageModel.fromJson(Map<String, dynamic> json) {
    return SupportMessageModel(
      uuid: json['uuid'] ?? '',
      sender: json['sender'] ?? '',
      body: json['body'] ?? '',
      createdAt:
          DateTime.tryParse(json['created_at'] ?? '')?.toLocal() ??
          DateTime.now(),
    );
  }

  SupportMessageModel copyWith({bool? pending, bool? failed}) {
    return SupportMessageModel(
      uuid: uuid,
      sender: sender,
      body: body,
      createdAt: createdAt,
      pending: pending ?? this.pending,
      failed: failed ?? this.failed,
    );
  }
}
