import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/websocket/websocket_provider.dart';
import '../../../../core/websocket/websocket_service.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../schedule/presentation/pages/schedule_page.dart';
import '../widgets/main_header.dart';

class MainNavigationPage extends ConsumerStatefulWidget {
  const MainNavigationPage({super.key});

  @override
  ConsumerState<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends ConsumerState<MainNavigationPage> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    HomePage(),
    DashboardPage(),
    SchedulePage(),
    ProfilePage(),
  ];

  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final wsStatusAsync = ref.watch(webSocketStatusProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F2),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const MainHeader(),
                Expanded(
                  child: IndexedStack(
                    index: currentIndex,
                    children: pages,
                  ),
                ),
              ],
            ),
          ),
          // Overlay de desconexão (Stream-based)
          wsStatusAsync.when(
            data: (status) => status == WebSocketStatus.disconnected
                ? _buildConnectionLostOverlay()
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => _buildConnectionLostOverlay(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppShadows.pressedShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(index: 0, icon: Icons.home, label: 'Inicio'),
            _navItem(index: 1, icon: Icons.area_chart, label: 'Estatisticas'),
            _navItem(index: 2, icon: Icons.calendar_month, label: 'Agendamentos'),
            _navItem(index: 3, icon: Icons.person, label: 'Perfil'),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionLostOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.orange),
              const SizedBox(height: 24),
              const Text(
                'Conexão Perdida',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D3520),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Estamos tentando restabelecer a comunicação com o servidor de jardinagem...',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1D3520)),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => ref.read(webSocketServiceProvider).connect(),
                child: const Text(
                  'Tentar Agora',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1D3520)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool selected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected ? Colors.white : Colors.black54,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
