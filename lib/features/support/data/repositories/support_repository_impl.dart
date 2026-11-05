import 'package:dio/dio.dart';
import '../datasources/support_remote_datasource.dart';
import '../models/help_content_model.dart';
import '../models/legal_document_model.dart';
import '../models/support_message_model.dart';
import '../../domain/repositories/support_repository.dart';
import '../../../../core/network/api_exception.dart';

class SupportRepositoryImpl implements SupportRepository {
  final SupportRemoteDataSource _remoteDataSource;

  SupportRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<LegalDocumentModel>> getLegalDocuments() async {
    try {
      final data = await _remoteDataSource.getLegalDocuments();
      return data.map((json) => LegalDocumentModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<HelpContentModel>> getHelpContents(String category) async {
    try {
      final data = await _remoteDataSource.getHelpContents(category);
      return data.map(HelpContentModel.fromJson).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<SupportMessageModel>> getSupportMessages() async {
    try {
      final data = await _remoteDataSource.getSupportMessages();
      return data.map(SupportMessageModel.fromJson).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<SupportMessageModel> sendSupportMessage(String body) async {
    try {
      final data = await _remoteDataSource.sendSupportMessage(body);
      return SupportMessageModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
