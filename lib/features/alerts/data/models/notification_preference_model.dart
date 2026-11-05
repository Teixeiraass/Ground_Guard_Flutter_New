class NotificationPreferenceModel {
  final String type;
  final bool enabled;

  const NotificationPreferenceModel({required this.type, required this.enabled});

  factory NotificationPreferenceModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferenceModel(
      type: json['type'] ?? '',
      enabled: json['enabled'] ?? true,
    );
  }

  NotificationPreferenceModel copyWith({bool? enabled}) {
    return NotificationPreferenceModel(
      type: type,
      enabled: enabled ?? this.enabled,
    );
  }
}

/// Rótulos em PT-BR por tipo — o backend só manda a constante (ex:
/// "AUTO_IRRIGATION_START"), igual ao padrão já usado para os dias da semana.
String notificationTypeLabel(String type) {
  switch (type) {
    case 'AUTO_IRRIGATION_START':
      return 'Irrigação automática';
    case 'LOW_HUMIDITY':
      return 'Umidade baixa';
    case 'BATTERY_LOW':
      return 'Bateria fraca';
    default:
      return type;
  }
}

String notificationTypeDescription(String type) {
  switch (type) {
    case 'AUTO_IRRIGATION_START':
      return 'Avisa antes de uma irrigação automática começar.';
    case 'LOW_HUMIDITY':
      return 'Avisa quando a umidade do solo estiver baixa.';
    case 'BATTERY_LOW':
      return 'Avisa quando a bateria de um sensor estiver acabando.';
    default:
      return '';
  }
}
