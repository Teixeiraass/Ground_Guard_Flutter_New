import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/support_provider.dart';

class TermsAndServicesPage extends ConsumerWidget {
  const TermsAndServicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final termsAsync = ref.watch(termsAndServicesProvider);

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
      body: termsAsync.when(
        data: (doc) {
          if (doc == null) {
            return const Center(child: Text('Nenhum documento de termos encontrado.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderImage(),
                const SizedBox(height: 32),
                _buildDynamicContent(doc.content),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    'Versão: ${doc.version}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro ao carregar termos: $err')),
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

  Widget _buildDynamicContent(String content) {
    // Split content by '#' to identify headers and sections
    final sections = content.split('#').where((s) => s.trim().isNotEmpty).toList();
    
    return Column(
      children: sections.map((section) {
        final lines = section.trim().split('\n');
        final title = lines[0].trim();
        final body = lines.sublist(1).join('\n').trim();
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _buildTermCard(
            icon: _getIconForTitle(title),
            title: title.toUpperCase(),
            content: body,
            borderColor: title.toLowerCase().contains('isenção') ? Colors.red.shade100 : null,
          ),
        );
      }).toList(),
    );
  }

  IconData _getIconForTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('aceitação')) return Icons.diamond_outlined;
    if (t.contains('uso')) return Icons.router_outlined;
    if (t.contains('privacidade')) return Icons.shield_outlined;
    if (t.contains('isenção')) return Icons.warning_amber_rounded;
    return Icons.description_outlined;
  }

  Widget _buildTermCard({
    required IconData icon,
    required String title,
    required String content,
    Color? borderColor,
  }) {
    // Check if content has a quote (enclosed in double quotes)
    String? quote;
    String cleanContent = content;
    
    if (content.contains('"')) {
      final startIndex = content.indexOf('"');
      final endIndex = content.lastIndexOf('"');
      if (startIndex != -1 && endIndex != -1 && startIndex < endIndex) {
        quote = content.substring(startIndex, endIndex + 1);
        cleanContent = (content.substring(0, startIndex) + content.substring(endIndex + 1)).trim();
      }
    }

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
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B5A2B),
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (quote != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
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
            cleanContent,
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
