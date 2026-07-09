import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: 'Vamos aos primeiros passos',
      description: 'Prepare o seu ambiente para a melhor experiência de jardinagem inteligente. Certifique-se de que o Bluetooth e o Wi-Fi do seu celular estão ligados para começar a configuração do seu Ground Guard.',
      image: 'assets/images/onboarding_1.png',
      topBadgeIcon: '👋 Oi!',
      topBadgeColor: const Color(0xFFFDB64B),
    ),
    OnboardingStep(
      title: 'Conecte seu Dispositivo',
      description: 'Aponte a câmera para o QR Code localizado na lateral do seu dispositivo Ground Guard para identificá-lo automaticamente.',
      image: 'assets/images/onboarding_2.png',
      topBadgeIcon: Icons.qr_code_scanner_rounded,
      bottomBadgeIcon: Icons.eco,
    ),
    OnboardingStep(
      title: 'Configurar Rede',
      description: 'Agora, o Ground Guard precisa se conectar à sua rede Wi-Fi. No próximo passo, você deve selecionar sua rede doméstica e inserir a senha para que ele possa sincronizar com a nuvem e cuidar do seu jardim.',
      image: 'assets/images/onboarding_3.png',
      topBadgeIcon: Icons.wifi,
      footer: 'Segurança WPA3 habilitada por padrão.',
    ),
    OnboardingStep(
      title: 'Tudo Pronto!',
      description: 'Seu Ground Guard está configurado e pronto para cuidar das suas plantas. Agora é só aproveitar o seu jardim sempre verde e saudável.',
      image: 'assets/images/onboarding_4.png',
      topBadgeIcon: Icons.eco,
      bottomBadgeIcon: Icons.check_circle_outline,
      isLast: true,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.qrCodeDevice);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: _currentPage > 0 
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1D3520)),
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            )
          : null,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.eco_rounded, color: Color(0xFF1D3520)),
            const SizedBox(width: 8),
            const Text(
              'Ground Guard',
              style: TextStyle(
                color: Color(0xFF1D3520),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildProgressIndicator(),
          const SizedBox(height: 8),
          Text(
            'Etapa ${_currentPage + 1} de 4',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                return _buildStep(_steps[index]);
              },
            ),
          ),
          _buildBottomAction(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        Color barColor = Colors.grey.shade200;
        if (index < _currentPage) {
          barColor = const Color(0xFFFDB64B); // Orange for completed
        } else if (index == _currentPage) {
          barColor = const Color(0xFF1D3520); // Dark Green for current
        }
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 40,
          height: 6,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  Widget _buildStep(OnboardingStep step) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.asset(
                    step.image,
                    height: 320,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 320,
                      color: Colors.white,
                      child: const Icon(Icons.image_outlined, size: 100, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              if (step.topBadgeIcon != null)
                Positioned(
                  top: 20,
                  right: -15,
                  child: _buildBadge(step.topBadgeIcon!, step.topBadgeColor),
                ),
              if (step.bottomBadgeIcon != null)
                Positioned(
                  bottom: step.isLast ? 40 : 20,
                  left: -15,
                  child: _buildBadge(step.bottomBadgeIcon!, step.bottomBadgeColor),
                ),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1D3520),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Text(
              step.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
          if (step.footer != null) ...[
            const SizedBox(height: 16),
            Text(
              step.footer!,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
          ],
           if (step.isLast) ...[
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {},
              child: Text(
                'Deseja revisar as configurações?',
                style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadge(dynamic icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: icon is String 
        ? Text(icon, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1D3520)))
        : Icon(icon as IconData, color: const Color(0xFF1D3520), size: 24),
    );
  }

  Widget _buildBottomAction() {
    final bool isLast = _currentPage == _steps.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: ElevatedButton(
        onPressed: _nextPage,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1D3520),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 64),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLast ? 'Começar Agora' : 'Próximo',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward),
          ],
        ),
      ),
    );
  }
}

class OnboardingStep {
  final String title;
  final String description;
  final String image;
  final dynamic topBadgeIcon;
  final Color topBadgeColor;
  final dynamic bottomBadgeIcon;
  final Color bottomBadgeColor;
  final String? footer;
  final bool isLast;

  OnboardingStep({
    required this.title,
    required this.description,
    required this.image,
    this.topBadgeIcon,
    this.topBadgeColor = Colors.white,
    this.bottomBadgeIcon,
    this.bottomBadgeColor = Colors.white,
    this.footer,
    this.isLast = false,
  });
}
