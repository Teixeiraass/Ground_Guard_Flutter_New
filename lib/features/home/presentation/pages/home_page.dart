import 'package:flutter/material.dart';
import '../widgets/info_card.dart';
import '../widgets/garden_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainCard(),
                  const SizedBox(height: 28),
                  _buildIrrigateButton(),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Pressione para iniciar ciclo de 15 min',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 34),
                  _buildZonesTitle(),
                  const SizedBox(height: 20),
                  _buildZonesGrid(),
                  const SizedBox(height: 28),
                  _buildWeatherAlert(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5EF),
        borderRadius: BorderRadius.circular(36),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jardim\nSaudável',
                      style: TextStyle(
                        fontSize: 22,
                        height: 1.2,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF214225),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Próxima rega hoje às\n18:30',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFCDEBC2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  children: [
                    Text(
                      '92%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Color(0xFF214225),
                      ),
                    ),
                    Text(
                      'Vitalidade',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF214225),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          _buildHumidityCircle(),
          const SizedBox(height: 34),
          const Row(
            children: [
              Expanded(
                child: InfoCard(
                  icon: Icons.thermostat_outlined,
                  title: 'Temperatura',
                  value: '24°C',
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: InfoCard(
                  icon: Icons.wb_sunny_outlined,
                  title: 'UV Index',
                  value: 'Médio',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHumidityCircle() {
    return Container(
      width: 170,
      height: 170,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFF5B041),
          width: 12,
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.water_drop_outlined,
            size: 34,
            color: Color(0xFF8B5A00),
          ),
          SizedBox(height: 6),
          Text(
            '70%',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Color(0xFF214225),
            ),
          ),
          Text(
            'Umidade',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIrrigateButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B4B16), Color(0xFF123E15)],
        ),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.water_drop_outlined, color: Colors.white),
          SizedBox(width: 10),
          Text(
            'Irrigar Agora',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZonesTitle() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Zonas do Jardim',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF214225),
            ),
          ),
        ),
        Text(
          'Ver tudo',
          style: TextStyle(
            fontSize: 16,
            color: Colors.green.shade900,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildZonesGrid() {
    return const Row(
      children: [
        Expanded(
          child: GardenCard(
            icon: Icons.grass,
            title: 'Gramado Frontal',
            humidity: '65% Umidade',
            humidityColor: Color(0xFFE09B2D),
            enabled: false,
            iconBg: Color(0xFFCDEBC2),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: GardenCard(
            icon: Icons.yard,
            title: 'Horta de\nTemperos',
            humidity: '42% (Seco)',
            humidityColor: Colors.red,
            enabled: true,
            iconBg: Color(0xFFF8D4D1),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherAlert() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFD9),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.cloud_outlined,
              color: Color(0xFF214225),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Previsão de Chuva',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF214225),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pode chover amanhã cedo.\nEconomia de 25L estimada.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
