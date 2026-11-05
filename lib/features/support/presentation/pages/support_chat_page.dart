import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ground_guard_app/core/theme/app_colors.dart';
import '../../data/models/support_message_model.dart';
import '../providers/support_provider.dart';

class SupportChatPage extends ConsumerStatefulWidget {
  const SupportChatPage({super.key});

  @override
  ConsumerState<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends ConsumerState<SupportChatPage> {
  final _controller = TextEditingController();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final canSend = _controller.text.trim().isNotEmpty;
      if (canSend != _canSend) setState(() => _canSend = canSend);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    _controller.clear();
    ref.read(supportChatProvider.notifier).send(text);
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(supportChatProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Column(
          children: [
            Text('Suporte Ground Guard'),
            Text(
              'Respondemos em horário comercial',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessages(chat)),
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildMessages(SupportChatState chat) {
    if (chat.loading && chat.messages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (chat.error != null && chat.messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, color: Colors.grey, size: 40),
              const SizedBox(height: 12),
              const Text(
                'Não foi possível carregar a conversa.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              TextButton(
                onPressed: () => ref.read(supportChatProvider.notifier).load(),
                child: const Text('Tentar de novo'),
              ),
            ],
          ),
        ),
      );
    }

    final messages = chat.messages;

    // Reversed list: index 0 is the newest message, at the bottom.
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: messages.length + 1,
      itemBuilder: (context, index) {
        if (index == messages.length) return const _WelcomeBubble();

        final message = messages[index];
        final older = index + 1 < messages.length ? messages[index + 1] : null;
        final showDay =
            older == null || !_sameDay(older.createdAt, message.createdAt);

        return Column(
          children: [
            if (showDay) _DayLabel(date: message.createdAt),
            _MessageBubble(
              message: message,
              onRetry: () =>
                  ref.read(supportChatProvider.notifier).retry(message),
            ),
          ],
        );
      },
    );
  }

  Widget _buildComposer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 5,
                  maxLength: 2000,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Escreva sua mensagem...',
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.surfaceContainer,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: _canSend ? 1 : 0.4,
                child: Material(
                  color: AppColors.primary,
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: _canSend ? _send : null,
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _WelcomeBubble extends StatelessWidget {
  const _WelcomeBubble();

  @override
  Widget build(BuildContext context) {
    return const _Bubble(
      fromUser: false,
      child: Text(
        'Olá! Este é o canal direto com o time do Ground Guard. '
        'Conte o que está acontecendo e responderemos aqui mesmo. '
        'Você também recebe uma notificação quando chegar a resposta.',
        style: TextStyle(color: Color(0xFF1D3520), height: 1.4),
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  final DateTime date;

  const _DayLabel({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;

    final label = diff == 0
        ? 'Hoje'
        : diff == 1
        ? 'Ontem'
        : DateFormat('dd/MM/yyyy').format(date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.outline),
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final SupportMessageModel message;
  final VoidCallback onRetry;

  const _MessageBubble({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final fromUser = message.isFromUser;
    final textColor = fromUser ? Colors.white : const Color(0xFF1D3520);
    final metaColor = fromUser ? Colors.white70 : AppColors.outline;

    final bubble = _Bubble(
      fromUser: fromUser,
      failed: message.failed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              message.body,
              style: TextStyle(color: textColor, height: 1.4),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('HH:mm').format(message.createdAt),
                style: TextStyle(fontSize: 11, color: metaColor),
              ),
              if (message.pending) ...[
                const SizedBox(width: 4),
                Icon(Icons.schedule_rounded, size: 12, color: metaColor),
              ],
            ],
          ),
        ],
      ),
    );

    if (!message.failed) return bubble;

    return GestureDetector(
      onTap: onRetry,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          bubble,
          const Padding(
            padding: EdgeInsets.only(bottom: 8, right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 14,
                  color: AppColors.error,
                ),
                SizedBox(width: 4),
                Text(
                  'Não enviada. Toque para tentar de novo.',
                  style: TextStyle(fontSize: 12, color: AppColors.error),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final bool fromUser;
  final bool failed;
  final Widget child;

  const _Bubble({
    required this.fromUser,
    required this.child,
    this.failed = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = fromUser
        ? (failed ? AppColors.primary.withOpacity(0.55) : AppColors.primary)
        : Colors.white;

    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(fromUser ? 20 : 6),
              bottomRight: Radius.circular(fromUser ? 6 : 20),
            ),
            boxShadow: fromUser
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: child,
        ),
      ),
    );
  }
}
