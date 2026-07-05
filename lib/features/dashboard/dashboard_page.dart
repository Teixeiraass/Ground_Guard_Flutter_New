import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.eco_rounded, color: Color(0xFF2D4029)),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Ground Guard',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1D3520),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: const Icon(Icons.notifications_none_rounded, color: Color(0xFF1D3520)),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              const Text(
                'Estatísticas por Zona',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1D3520),
                ),
              ),
              const Text(
                'Visão detalhada do seu ecossistema.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 24),
              // FILTROS
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Visão Geral', isSelected: true),
                    _buildFilterChip('Jardim Frontal'),
                    _buildFilterChip('Horta'),
                    _buildFilterChip('Pomar'),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              // CARD UMIDADE DO SOLO
              _buildMainCard(
                title: 'Umidade do Solo',
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _buildCircularIndicator(65, 'Ideal'),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(child: _buildMiniStatCard('Mínimo', '42%')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildMiniStatCard('Máxima', '78%')),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),
              // CARD CONSUMO DE ÁGUA
              _buildMainCard(
                title: 'Consumo de Água',
                trailing: _buildSmallChip('Últimos 7 dias'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildBarChart(),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total da Semana', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            Text('142.5 Litros', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1D3520))),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.trending_up_rounded, color: Colors.orange, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '12%',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                            ),
                            const Text(' vs. anterior', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 32),
              // HISTÓRICO
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'HISTÓRICO DE IRRIGAÇÃO',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Ver todos', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),

              _buildHistoryItem('Hoje, 06:30 AM', 'Ciclo Automático', '15m 45s', '12.4 L', Icons.water_drop_rounded, const Color(0xFFD4E9D5)),
              _buildHistoryItem('Ontem, 08:15 PM', 'Início Manual', '05m 00s', '4.0 L', Icons.touch_app_rounded, const Color(0xFFFDE9C2)),
              _buildHistoryItem('22 Mai, 06:30 AM', 'Ciclo Automático', '12m 30s', '10.1 L', Icons.water_drop_rounded, const Color(0xFFD4E9D5)),

              const SizedBox(height: 24),
              // FOOTER CARDS
              Row(
                children: [
                  Expanded(child: _buildFooterInfoCard('Próxima Chuva', 'Sexta', '80% Probabilidade', Icons.wb_sunny_outlined, const Color(0xFFFDE9C2))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildFooterInfoCard('Temp. Solo', '24°C', 'Estável', Icons.thermostat_rounded, const Color(0xFFFFE7E2))),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2D4029) : Colors.white,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMainCard({required String title, required Widget child, Widget? trailing}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1D3520)),
              ),
              ?trailing,
            ],
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildCircularIndicator(double value, String label) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 180,
          width: 180,
          child: CircularProgressIndicator(
            value: value / 100,
            strokeWidth: 15,
            backgroundColor: const Color(0xFFF4F4F4),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF5B544)),
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${value.toInt()}%',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF1D3520)),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildMiniStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1D3520))),
        ],
      ),
    );
  }

  Widget _buildSmallChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F4EB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2D4029)),
      ),
    );
  }

  Widget _buildBarChart() {
    final List<double> heights = [0.4, 0.7, 0.5, 0.9, 0.6, 0.8, 0.4];
    final List<String> days = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        return Column(
          children: [
            Container(
              height: 100 * heights[index],
              width: 12,
              decoration: BoxDecoration(
                color: index == 3 ? const Color(0xFF2D4029) : const Color(0xFFE9F4EB),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Text(days[index], style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        );
      }),
    );
  }

  Widget _buildHistoryItem(String time, String type, String duration, String water, IconData icon, Color iconBg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: const Color(0xFF2D4029)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1D3520))),
                Text(type, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(duration, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1D3520))),
              Text(water, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFooterInfoCard(String title, String value, String sub, IconData icon, Color iconBg) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: const Color(0xFF1D3520)),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1D3520))),
          Text(sub, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}
