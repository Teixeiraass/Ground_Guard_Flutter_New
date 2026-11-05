import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../data/soil_health_model.dart';

const soilWetColor = Color(0xFF0277BD);
const soilDryColor = Color(0xFFEF6C00);
const soilOkColor = Color(0xFF2E7D32);

String soilHealthLabel(String status) {
  switch (status) {
    case 'EXCELLENT':
      return 'Ótima';
    case 'GOOD':
      return 'Boa';
    case 'ATTENTION':
      return 'Atenção';
    case 'CRITICAL':
      return 'Crítica';
    case 'NO_DEVICES':
      return 'Sem sensores';
    default:
      return 'Sem dados';
  }
}

Color soilHealthColor(String status) {
  switch (status) {
    case 'EXCELLENT':
      return soilOkColor;
    case 'GOOD':
      return const Color(0xFF689F38);
    case 'ATTENTION':
      return soilDryColor;
    case 'CRITICAL':
      return AppColors.error;
    default:
      return AppColors.outline;
  }
}

String sensorStateLabel(String state) {
  switch (state) {
    case 'OK':
      return 'Na faixa ideal';
    case 'DRY':
      return 'Seco';
    case 'WET':
      return 'Encharcado';
    case 'OFFLINE':
      return 'Offline';
    case 'FAULT':
      return 'Sensor com falha';
    default:
      return 'Sem leitura';
  }
}

Color sensorStateColor(String state) {
  switch (state) {
    case 'OK':
      return soilOkColor;
    case 'DRY':
      return soilDryColor;
    case 'WET':
      return soilWetColor;
    case 'FAULT':
      return AppColors.error;
    default:
      return AppColors.outline;
  }
}

IconData sensorStateIcon(String state) {
  switch (state) {
    case 'OK':
      return Icons.check_circle_rounded;
    case 'DRY':
      return Icons.wb_sunny_rounded;
    case 'WET':
      return Icons.water_rounded;
    case 'OFFLINE':
      return Icons.wifi_off_rounded;
    case 'FAULT':
      return Icons.sensors_off_rounded;
    default:
      return Icons.hourglass_empty_rounded;
  }
}

/// Short, actionable advice derived from what the sensors are reporting.
List<String> soilHealthAdvice(SoilHealthModel health) {
  final s = health.summary;
  final tips = <String>[];

  if (s.total == 0) {
    return [
      'Adicione um sensor de solo para começar a acompanhar a saúde do seu jardim.',
    ];
  }
  if (s.fault > 0) {
    tips.add(
      '${_count(s.fault, 'sensor está', 'sensores estão')} com leitura inválida. '
      'Confira se o cabo está bem encaixado e se a ponta está enterrada.',
    );
  }
  if (s.offline > 0) {
    tips.add(
      '${_count(s.offline, 'sensor está', 'sensores estão')} sem enviar dados. '
      'Verifique a energia e o Wi-Fi da controladora.',
    );
  }
  if (s.dry > 0) {
    tips.add(
      '${_count(s.dry, 'zona está', 'zonas estão')} com o solo seco. '
      'Considere regar agora ou aumentar o tempo dos agendamentos.',
    );
  }
  if (s.wet > 0) {
    tips.add(
      '${_count(s.wet, 'zona está', 'zonas estão')} encharcada${s.wet == 1 ? '' : 's'}. '
      'Reduza a frequência de rega e confira a drenagem.',
    );
  }
  if (tips.isEmpty && health.score != null) {
    tips.add(
      'Tudo certo! Seus sensores estão dentro da faixa ideal de umidade.',
    );
  }
  return tips;
}

String _count(int n, String singular, String plural) =>
    n == 1 ? '1 $singular' : '$n $plural';
