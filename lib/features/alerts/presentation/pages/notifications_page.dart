import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notificações'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Marcar todas como lidas',
                  style: TextStyle(
                    color: AppColors.primary.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vertical(10),
          _buildSectionHeader('Hoje'),
          AppSpacing.vertical(16),
          _buildNotificationItem(
            context,
            title: 'Rega concluída',
            description: 'A rega no Jardim Frontal foi finalizada com sucesso. 12L consumidos.',
            time: 'Agora',
            icon: Icons.water_drop_outlined,
            iconColor: Colors.green,
            iconBg: const Color(0xFFEFF4EA),
            isDismissible: true,
          ),
          AppSpacing.vertical(12),
          _buildNotificationItem(
            context,
            title: 'Bateria baixa',
            description: 'O sensor de umidade da Horta está com 5% de carga. Considere carregar hoje.',
            time: '2h atrás',
            icon: Icons.battery_alert_rounded,
            iconColor: Colors.brown,
            iconBg: const Color(0xFFFFF4E5),
          ),
          AppSpacing.vertical(12),
          _buildNotificationItem(
            context,
            title: 'Aviso de Clima',
            description: 'Previsão de chuva forte para amanhã. Agendamento de rega pausado preventivamente.',
            time: '4h atrás',
            icon: Icons.wb_cloudy_outlined,
            iconColor: Colors.grey,
            iconBg: const Color(0xFFF5F5F5),
          ),
          AppSpacing.vertical(32),
          _buildSectionHeader('Ontem'),
          AppSpacing.vertical(16),
          _buildNotificationItem(
            context,
            title: 'Relatório Semanal',
            description: 'Suas plantas cresceram 12% mais rápido esta semana comparado ao mês passado.',
            time: 'Ontem, 08:30',
            icon: Icons.eco_outlined,
            iconColor: Colors.green,
            iconBg: const Color(0xFFEFF4EA),
          ),
          AppSpacing.vertical(12),
          _buildNotificationItem(
            context,
            title: 'Novo Dispositivo',
            description: "Gateway 'Solo-Link-04' foi configurado e está operacional.",
            time: 'Ontem, 16:15',
            icon: Icons.router_outlined,
            iconColor: Colors.grey,
            iconBg: const Color(0xFFF5F5F5),
          ),
          AppSpacing.vertical(32),
          _buildStatusCard(),
          AppSpacing.vertical(40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(
    BuildContext context, {
    required String title,
    required String description,
    required String time,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    bool isDismissible = false,
  }) {
    Widget card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF825500),
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isDismissible) {
      return Dismissible(
        key: Key(title),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red.shade800,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          child: const Icon(Icons.delete_outline, color: Colors.white),
        ),
        child: card,
      );
    }

    return card;
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F6),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFC7ECC2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.help_outline, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 24),
          const Text(
            'Tudo em ordem',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Seu ecossistema está saudável.\nNenhuma ação crítica no momento.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
