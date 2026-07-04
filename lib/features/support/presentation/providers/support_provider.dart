import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/support_remote_datasource.dart';
import '../../data/repositories/support_repository_impl.dart';
import '../../domain/repositories/support_repository.dart';
import '../../data/models/legal_document_model.dart';

final supportRemoteDataSourceProvider = Provider<SupportRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return SupportRemoteDataSourceImpl(dio);
});

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  final remoteDataSource = ref.watch(supportRemoteDataSourceProvider);
  return SupportRepositoryImpl(remoteDataSource);
});

final legalDocumentsProvider = FutureProvider<List<LegalDocumentModel>>((ref) async {
  final repository = ref.watch(supportRepositoryProvider);
  return repository.getLegalDocuments();
});

final termsAndServicesProvider = Provider<AsyncValue<LegalDocumentModel?>>((ref) {
  final docsAsync = ref.watch(legalDocumentsProvider);
  
  return docsAsync.whenData((docs) {
    try {
      return docs.firstWhere((doc) => doc.type == 'TERMS' && doc.active);
    } catch (_) {
      return null;
    }
  });
});
