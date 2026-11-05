import 'package:flutter/material.dart';

class HelpCategory {
  final String key;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color background;
  final Color foreground;

  const HelpCategory({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  static const firstSteps = HelpCategory(
    key: 'FIRST_STEPS',
    title: 'Primeiros Passos',
    subtitle: 'Do unboxing ao primeiro sensor funcionando.',
    icon: Icons.rocket_launch_outlined,
    background: Color(0xFFE8F5E9),
    foreground: Color(0xFF2E7D32),
  );

  static const tips = HelpCategory(
    key: 'TIPS',
    title: 'Dicas de Cultivo',
    subtitle: 'Práticas simples para um solo saudável e menos desperdício.',
    icon: Icons.eco_outlined,
    background: Color(0xFFE8F5E9),
    foreground: Color(0xFF2E7D32),
  );

  static const all = [
    firstSteps,
    HelpCategory(
      key: 'IOT',
      title: 'Conectividade IOT',
      subtitle: 'Wi-Fi, Bluetooth e dispositivos offline.',
      icon: Icons.router_outlined,
      background: Color(0xFFFFF3E0),
      foreground: Color(0xFFEF6C00),
    ),
    HelpCategory(
      key: 'IRRIGATION',
      title: 'Configuração de Rega',
      subtitle: 'Rega manual, agendamentos e automação.',
      icon: Icons.water_drop_outlined,
      background: Color(0xFFE1F5FE),
      foreground: Color(0xFF0277BD),
    ),
    HelpCategory(
      key: 'ACCOUNT',
      title: 'Conta e Privacidade',
      subtitle: 'Seus dados, senha e segurança da conta.',
      icon: Icons.shield_outlined,
      background: Color(0xFFFFEBEE),
      foreground: Color(0xFFC62828),
    ),
  ];
}
