import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ground_guard_app/core/routes/app_routes.dart';
import 'package:ground_guard_app/core/theme/app_colors.dart';
import '../../data/models/help_content_model.dart';
import '../help_categories.dart';
import '../providers/support_provider.dart';

class HelpCategoryPage extends ConsumerWidget {
  final HelpCategory category;

  const HelpCategoryPage({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articlesAsync = ref.watch(helpContentsProvider(category.key));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(category.title),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.refresh(helpContentsProvider(category.key).future),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            _Header(category: category),
            const SizedBox(height: 24),
            if (category.key == HelpCategory.firstSteps.key) ...[
              _TutorialCard(category: category),
              const SizedBox(height: 16),
            ],
            ...articlesAsync.when(
              loading: () => const [
                Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ],
              error: (err, _) => [
                _MessageBox(
                  icon: Icons.cloud_off_rounded,
                  text: 'Não foi possível carregar os artigos.\n$err',
                  actionLabel: 'Tentar de novo',
                  onAction: () =>
                      ref.invalidate(helpContentsProvider(category.key)),
                ),
              ],
              data: (articles) => articles.isEmpty
                  ? const [
                      _MessageBox(
                        icon: Icons.menu_book_outlined,
                        text: 'Ainda não há artigos nesta categoria.',
                      ),
                    ]
                  : [
                      for (final article in articles) ...[
                        _ArticleTile(
                          article: article,
                          accent: category.foreground,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
            ),
            const SizedBox(height: 20),
            const _StillNeedHelp(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final HelpCategory category;

  const _Header({required this.category});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: category.background,
            shape: BoxShape.circle,
          ),
          child: Icon(category.icon, color: category.foreground, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            category.subtitle,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF424840),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _TutorialCard extends StatelessWidget {
  final HelpCategory category;

  const _TutorialCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.pushNamed(context, AppRoutes.onboarding),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                Icons.play_circle_outline_rounded,
                color: Colors.white,
                size: 32,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ver tutorial de configuração',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'O passo a passo para instalar uma nova controladora.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArticleTile extends StatelessWidget {
  final HelpContentModel article;
  final Color accent;

  const _ArticleTile({required this.article, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          iconColor: accent,
          collapsedIconColor: Colors.grey,
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          title: Text(
            article.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D3520),
            ),
          ),
          children: [
            Text(
              article.content,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF424840),
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageBox({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey, size: 40),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class _StillNeedHelp extends StatelessWidget {
  const _StillNeedHelp();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.mintAccent.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Não encontrou o que procurava?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D3520),
              ),
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.supportChat),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text(
              'Falar com o time',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
