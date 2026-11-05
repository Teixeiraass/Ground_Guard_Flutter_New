import '../../data/models/help_content_model.dart';
import '../../data/models/legal_document_model.dart';
import '../../data/models/support_message_model.dart';

abstract class SupportRepository {
  Future<List<LegalDocumentModel>> getLegalDocuments();
  Future<List<HelpContentModel>> getHelpContents(String category);
  Future<List<SupportMessageModel>> getSupportMessages();
  Future<SupportMessageModel> sendSupportMessage(String body);
}
