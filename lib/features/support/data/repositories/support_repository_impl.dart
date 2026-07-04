import 'package:dio/dio.dart';
import '../datasources/support_remote_datasource.dart';
import '../models/legal_document_model.dart';
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
}
