import '../../data/models/legal_document_model.dart';

abstract class SupportRepository {
  Future<List<LegalDocumentModel>> getLegalDocuments();
}
