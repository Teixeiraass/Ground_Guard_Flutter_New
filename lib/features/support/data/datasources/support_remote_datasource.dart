import 'package:dio/dio.dart';

abstract class SupportRemoteDataSource {
  Future<List<Map<String, dynamic>>> getLegalDocuments();
}

class SupportRemoteDataSourceImpl implements SupportRemoteDataSource {
  final Dio _dio;

  SupportRemoteDataSourceImpl(this._dio);

  @override
  Future<List<Map<String, dynamic>>> getLegalDocuments() async {
    try {
      final response = await _dio.get('/legal-documents', queryParameters: {
        'page_id': 1,
        'page_size': 10,
      });
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
