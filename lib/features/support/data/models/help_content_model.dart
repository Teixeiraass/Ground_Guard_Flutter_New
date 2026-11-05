class HelpContentModel {
  final String uuid;
  final String title;
  final String category;
  final String content;
  final int orderNumber;

  HelpContentModel({
    required this.uuid,
    required this.title,
    required this.category,
    required this.content,
    required this.orderNumber,
  });

  factory HelpContentModel.fromJson(Map<String, dynamic> json) {
    return HelpContentModel(
      uuid: json['uuid'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      content: json['content'] ?? '',
      orderNumber: (json['order_number'] as num?)?.toInt() ?? 0,
    );
  }
}
