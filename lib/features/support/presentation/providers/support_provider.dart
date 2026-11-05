import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/websocket/websocket_provider.dart';
import '../../../../core/websocket/websocket_service.dart';
import '../../data/datasources/support_remote_datasource.dart';
import '../../data/models/help_content_model.dart';
import '../../data/models/support_message_model.dart';
import '../../data/repositories/support_repository_impl.dart';
import '../../domain/repositories/support_repository.dart';
import '../../data/models/legal_document_model.dart';

final supportRemoteDataSourceProvider = Provider<SupportRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  return SupportRemoteDataSourceImpl(dio);
});

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  final remoteDataSource = ref.watch(supportRemoteDataSourceProvider);
  return SupportRepositoryImpl(remoteDataSource);
});

final legalDocumentsProvider = FutureProvider<List<LegalDocumentModel>>((
  ref,
) async {
  final repository = ref.watch(supportRepositoryProvider);
  return repository.getLegalDocuments();
});

final termsAndServicesProvider = Provider<AsyncValue<LegalDocumentModel?>>((
  ref,
) {
  final docsAsync = ref.watch(legalDocumentsProvider);

  return docsAsync.whenData((docs) {
    try {
      return docs.firstWhere((doc) => doc.type == 'TERMS' && doc.active);
    } catch (_) {
      return null;
    }
  });
});

final helpContentsProvider = FutureProvider.autoDispose
    .family<List<HelpContentModel>, String>((ref, category) {
      return ref.watch(supportRepositoryProvider).getHelpContents(category);
    });

class SupportChatState {
  /// Newest first, matching the API order (rendered in a reversed list).
  final List<SupportMessageModel> messages;
  final bool loading;
  final String? error;

  const SupportChatState({
    this.messages = const [],
    this.loading = true,
    this.error,
  });

  SupportChatState copyWith({
    List<SupportMessageModel>? messages,
    bool? loading,
    String? error,
    bool clearError = false,
  }) {
    return SupportChatState(
      messages: messages ?? this.messages,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class SupportChatNotifier extends StateNotifier<SupportChatState> {
  final SupportRepository _repository;

  SupportChatNotifier(this._repository, Ref ref)
    : super(const SupportChatState()) {
    // Replies arrive over the websocket; a reconnect may have missed some.
    ref.listen(webSocketMessagesProvider, (_, next) {
      if (next.valueOrNull?.type == 'support_message') load();
    });
    ref.listen(webSocketStatusProvider, (prev, next) {
      final wasConnected = prev?.valueOrNull == WebSocketStatus.connected;
      if (!wasConnected && next.valueOrNull == WebSocketStatus.connected) {
        load();
      }
    });
    load();
  }

  Future<void> load() async {
    try {
      final fetched = await _repository.getSupportMessages();
      if (!mounted) return;
      final local = state.messages.where((m) => m.pending || m.failed);
      state = state.copyWith(
        messages: [...local, ...fetched],
        loading: false,
        clearError: true,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> send(String text) async {
    final body = text.trim();
    if (body.isEmpty) return;

    final temp = SupportMessageModel(
      uuid: 'local-${DateTime.now().microsecondsSinceEpoch}',
      sender: 'USER',
      body: body,
      createdAt: DateTime.now(),
      pending: true,
    );
    state = state.copyWith(messages: [temp, ...state.messages]);
    await _deliver(temp);
  }

  Future<void> retry(SupportMessageModel message) async {
    final pending = message.copyWith(pending: true, failed: false);
    state = state.copyWith(
      messages: [
        for (final m in state.messages)
          if (m.uuid == message.uuid) pending else m,
      ],
    );
    await _deliver(pending);
  }

  Future<void> _deliver(SupportMessageModel temp) async {
    try {
      final saved = await _repository.sendSupportMessage(temp.body);
      if (!mounted) return;
      state = state.copyWith(
        messages: [
          for (final m in state.messages)
            if (m.uuid == temp.uuid) saved else m,
        ],
      );
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(
        messages: [
          for (final m in state.messages)
            if (m.uuid == temp.uuid)
              m.copyWith(pending: false, failed: true)
            else
              m,
        ],
      );
    }
  }
}

final supportChatProvider =
    StateNotifierProvider.autoDispose<SupportChatNotifier, SupportChatState>((
      ref,
    ) {
      return SupportChatNotifier(ref.watch(supportRepositoryProvider), ref);
    });
