import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class TermsAndServicesPage extends StatelessWidget {
  const TermsAndServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Termos e Serviços'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderImage(),
            const SizedBox(height: 32),
            _buildTermCard(
              icon: Icons.diamond_outlined,
              title: 'ACEITAÇÃO DOS TERMOS',
              content: 'Ao usar o Ground Guard, você concorda com nossos termos de operação digital. Este sistema foi desenhado para harmonizar a tecnologia de automação com o cuidado orgânico das suas plantas, estabelecendo uma relação de confiança entre o zelador e o jardim.',
            ),
            const SizedBox(height: 20),
            _buildTermCard(
              icon: Icons.router_outlined,
              title: 'USO DO APLICATIVO',
              content: 'O uso indevido para fins não agrícolas ou modificações não autorizadas no hardware podem comprometer a garantia e a precisão dos dados coletados pelos sensores de solo.',
              quote: '"O sistema IOT deve ser usado apenas para fins de irrigação e monitoramento de saúde vegetal."',
            ),
            const SizedBox(height: 20),
            _buildTermCard(
              icon: Icons.shield_outlined,
              title: 'PRIVACIDADE',
              content: 'Seus dados de umidade e localização são protegidos com criptografia de ponta a ponta. Valorizamos a sua privacidade tanto quanto a saúde das suas flores. Informações sobre padrões de rega são utilizadas apenas para otimizar os algoritmos de economia de água do seu dispositivo.',
            ),
            const SizedBox(height: 20),
            _buildTermCard(
              icon: Icons.warning_amber_rounded,
              title: 'ISENÇÃO DE RESPONSABILIDADE',
              content: 'Embora busquemos a perfeição técnica, não nos responsabilizamos por plantas que morram devido a falhas de conectividade, bateria descarregada ou condições de clima extremo que superem a capacidade de drenagem do sistema.',
              borderColor: Colors.red.shade100,
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                'Última atualização: Outubro 2023',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: AssetImage('assets/images/termos_servicos.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.transparent,
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GROUND GUARD POLICY',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Digital Stewardship',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermCard({
    required IconData icon,
    required String title,
    required String content,
    String? quote,
    Color? borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: borderColor != null ? Border.all(color: borderColor) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF8B5A2B)),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B5A2B),
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (quote != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                quote,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
