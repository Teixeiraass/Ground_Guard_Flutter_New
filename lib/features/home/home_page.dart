import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F5),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 30),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),

                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/300',
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Olá, João!',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                            ),
                          ),

                          SizedBox(height: 2),

                          Text(
                            'Ground Guard',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF214225),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.notifications_none_rounded,
                      size: 28,
                      color: Color(0xFF214225),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    // MAIN CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),

                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F5EF),
                        borderRadius: BorderRadius.circular(36),
                      ),

                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Jardim\nSaudável',
                                      style: TextStyle(
                                        fontSize: 22,
                                        height: 1.2,
                                        fontWeight:
                                        FontWeight.bold,
                                        color:
                                        Color(0xFF214225),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    Text(
                                      'Próxima rega hoje às\n18:30',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors
                                            .grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),

                                decoration: BoxDecoration(
                                  color:
                                  const Color(0xFFCDEBC2),
                                  borderRadius:
                                  BorderRadius.circular(
                                      24),
                                ),

                                child: Column(
                                  children: const [
                                    Text(
                                      '92%',
                                      style: TextStyle(
                                        fontWeight:
                                        FontWeight.bold,
                                        fontSize: 22,
                                        color:
                                        Color(0xFF214225),
                                      ),
                                    ),

                                    Text(
                                      'Vitalidade',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color:
                                        Color(0xFF214225),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // HUMIDITY CIRCLE
                          Container(
                            width: 170,
                            height: 170,

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                const Color(0xFFF5B041),
                                width: 12,
                              ),
                            ),

                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: const [
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
                                    fontWeight:
                                    FontWeight.bold,
                                    color:
                                    Color(0xFF214225),
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
                          ),

                          const SizedBox(height: 34),

                          Row(
                            children: [
                              Expanded(
                                child: infoCard(
                                  icon:
                                  Icons.thermostat_outlined,
                                  title: 'Temperatura',
                                  value: '24°C',
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: infoCard(
                                  icon:
                                  Icons.wb_sunny_outlined,
                                  title: 'UV Index',
                                  value: 'Médio',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // BUTTON
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 22,
                      ),

                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF0B4B16),
                            Color(0xFF123E15),
                          ],
                        ),
                        borderRadius:
                        BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color:
                            Colors.black.withOpacity(0.1),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),

                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.water_drop_outlined,
                            color: Colors.white,
                          ),

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
                    ),

                    const SizedBox(height: 16),

                    Center(
                      child: Text(
                        'Pressione para iniciar ciclo de 15 min',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 15,
                        ),
                      ),
                    ),

                    const SizedBox(height: 34),

                    // TITLE
                    Row(
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
                    ),

                    const SizedBox(height: 20),

                    // ZONES
                    Row(
                      children: [
                        Expanded(
                          child: gardenCard(
                            icon: Icons.grass,
                            title: 'Gramado Frontal',
                            humidity: '65% Umidade',
                            humidityColor:
                            const Color(0xFFE09B2D),
                            enabled: false,
                            iconBg:
                            const Color(0xFFCDEBC2),
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: gardenCard(
                            icon: Icons.yard,
                            title: 'Horta de\nTemperos',
                            humidity: '42% (Seco)',
                            humidityColor: Colors.red,
                            enabled: true,
                            iconBg:
                            const Color(0xFFF8D4D1),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // WEATHER ALERT
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),

                      decoration: BoxDecoration(
                        color: const Color(0xFFF3EFD9),
                        borderRadius:
                        BorderRadius.circular(30),
                      ),

                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(
                                  18),
                            ),
                            child: const Icon(
                              Icons.cloud_outlined,
                              color: Color(0xFF214225),
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                const Text(
                                  'Previsão de Chuva',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                    FontWeight.bold,
                                    color:
                                    Color(0xFF214225),
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  'Pode chover amanhã cedo.\nEconomia de 25L estimada.',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors
                                        .grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 16,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFF214225),
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF214225),
            ),
          ),
        ],
      ),
    );
  }

  Widget gardenCard({
    required IconData icon,
    required String title,
    required String humidity,
    required Color humidityColor,
    required bool enabled,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFFF4F5EF),
        borderRadius: BorderRadius.circular(28),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF214225),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: humidityColor,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  humidity,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Switch(
                value: enabled,
                onChanged: (_) {},
                activeColor: Colors.white,
                activeTrackColor:
                const Color(0xFF123E15),
              ),

              const Spacer(),

              Icon(
                Icons.settings_outlined,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ],
      ),
    );
  }
}