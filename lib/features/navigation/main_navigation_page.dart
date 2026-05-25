import 'package:flutter/material.dart';
import 'package:ground_guard_app/core/theme/app_colors.dart';
import 'package:ground_guard_app/core/theme/app_shadows.dart';
import 'package:ground_guard_app/features/dashboard/dashboard_page.dart';
import 'package:ground_guard_app/features/schedule/presentation/pages/schedule_page.dart';
import '../home/home_page.dart';
import '../profile/profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
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
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppShadows.pressedShadow
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            navItem(
              index: 0,
              icon: Icons.home,
              label: 'Inicio',
            ),

            navItem(
              index: 1,
              icon: Icons.area_chart,
              label: 'Estatisticas',
            ),

            navItem(
              index: 2,
              icon: Icons.calendar_month,
              label: 'Agendamentos',
            ),

            navItem(
              index: 3,
              icon: Icons.settings,
              label: 'Configurações',
            ),
          ],
        ),
      ),
    );
  }

  Widget navItem({
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
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),

          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected
                    ? Colors.white
                    : Colors.black54,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}