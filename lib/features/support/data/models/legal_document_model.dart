class LegalDocumentModel {
  final String uuid;
  final String type;
  final String version;
  final String title;
  final String content;
  final bool active;

  LegalDocumentModel({
    required this.uuid,
    required this.type,
    required this.version,
    required this.title,
    required this.content,
    required this.active,
  });

  factory LegalDocumentModel.fromJson(Map<String, dynamic> json) {
    return LegalDocumentModel(
      uuid: json['uuid'] ?? '',
      type: json['type'] ?? '',
      version: json['version'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      active: json['active'] ?? false,
    );
  }
}
