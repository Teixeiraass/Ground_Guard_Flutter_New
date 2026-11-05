import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/websocket/websocket_provider.dart';
import '../../../../core/websocket/websocket_service.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../monitoring/presentation/pages/monitoring_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../schedule/presentation/pages/schedule_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../widgets/main_header.dart';

class MainNavigationPage extends ConsumerStatefulWidget {
  const MainNavigationPage({super.key});

  @override
  ConsumerState<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends ConsumerState<MainNavigationPage>
    with WidgetsBindingObserver {
  int currentIndex = 0;
  bool _isResuming = false;
  bool _showErrorOverlay = false;
  Timer? _resumeTimer;
  Timer? _overlayDelayTimer;

  final List<Widget> pages = const [
    HomePage(),
    DashboardPage(),
    MonitoringPage(),
    SchedulePage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _resumeTimer?.cancel();
    _overlayDelayTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _isResuming = true;
        _showErrorOverlay = false;
      });
      _overlayDelayTimer?.cancel();

      ref.read(webSocketServiceProvider).connect();

      _resumeTimer?.cancel();
      _resumeTimer = Timer(const Duration(seconds: 10), () {
        if (mounted) setState(() => _isResuming = false);
      });
    }
  }

  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authStatus = ref.watch(authProvider.select((s) => s.status));

    ref.listen<AsyncValue<WebSocketStatus>>(webSocketStatusProvider, (
      previous,
      next,
    ) {
      final status = next.valueOrNull;

      if (status == WebSocketStatus.connected) {
        _overlayDelayTimer?.cancel();
        if (mounted && (_showErrorOverlay || _isResuming)) {
          setState(() {
            _showErrorOverlay = false;
            _isResuming = false;
          });
        }
      } else if (status == WebSocketStatus.reconnecting ||
          status == WebSocketStatus.connecting) {
        if (!_showErrorOverlay &&
            !_isResuming &&
            (_overlayDelayTimer == null || !_overlayDelayTimer!.isActive)) {
          _overlayDelayTimer = Timer(const Duration(seconds: 5), () {
            if (mounted) setState(() => _showErrorOverlay = true);
          });
        }
      } else if (status == WebSocketStatus.disconnected) {
        _overlayDelayTimer?.cancel();
        if (mounted &&
            !_showErrorOverlay &&
            !_isResuming &&
            (authStatus == AuthStatus.authenticated ||
                authStatus == AuthStatus.authenticatedNoDevices)) {
          setState(() => _showErrorOverlay = true);
        }
      }
    });

    final bool shouldShowOverlay =
        _showErrorOverlay &&
        !_isResuming &&
        (authStatus == AuthStatus.authenticated ||
            authStatus == AuthStatus.authenticatedNoDevices);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F2),
      extendBody: true,
      body: Stack(
        children: [
          // bottom: false — with extendBody the nav bar height is part of the
          // bottom inset; consuming it here would stop content above the bar.
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const MainHeader(),
                Expanded(
                  child: IndexedStack(index: currentIndex, children: pages),
                ),
              ],
            ),
          ),
          if (shouldShowOverlay) _buildConnectionLostOverlay(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 12,
            top: 4,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            // Blur clipped to the pill only, so the margins around it show
            // the content untouched instead of a blurred rectangle strip.
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.62),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.6),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _navItem(
                        index: 0,
                        activeIcon: Icons.home_rounded,
                        inactiveIcon: Icons.home_outlined,
                        label: 'Início',
                      ),
                      _navItem(
                        index: 1,
                        activeIcon: Icons.bar_chart_rounded,
                        inactiveIcon: Icons.bar_chart_outlined,
                        label: 'Estatísticas',
                      ),
                      _navItem(
                        index: 2,
                        activeIcon: Icons.map_rounded,
                        inactiveIcon: Icons.map_outlined,
                        label: 'Mapa',
                      ),
                      _navItem(
                        index: 3,
                        activeIcon: Icons.calendar_month_rounded,
                        inactiveIcon: Icons.calendar_month_outlined,
                        label: 'Agenda',
                      ),
                      _navItem(
                        index: 4,
                        activeIcon: Icons.person_rounded,
                        inactiveIcon: Icons.person_outline_rounded,
                        label: 'Perfil',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
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
              const Icon(
                Icons.cloud_off_rounded,
                size: 64,
                color: Colors.orange,
              ),
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D3520),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required int index,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String label,
  }) {
    final bool selected = currentIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        splashColor: AppColors.primary.withOpacity(0.15),
        highlightColor: AppColors.primary.withOpacity(0.08),
        onTap: () {
          if (!selected) HapticFeedback.selectionClick();
          onTap(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: selected ? 16 : 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: selected ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                child: Icon(
                  selected ? activeIcon : inactiveIcon,
                  color: selected ? Colors.white : AppColors.outline,
                  size: 22,
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                child: selected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 7),
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                          ),
                        ),
                      )
                    : const SizedBox(width: 0, height: 0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
