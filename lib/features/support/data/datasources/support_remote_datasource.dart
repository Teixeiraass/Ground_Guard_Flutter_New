import 'package:dio/dio.dart';

abstract class SupportRemoteDataSource {
  Future<List<Map<String, dynamic>>> getLegalDocuments();
  Future<List<Map<String, dynamic>>> getHelpContents(String category);
  Future<List<Map<String, dynamic>>> getSupportMessages();
  Future<Map<String, dynamic>> sendSupportMessage(String body);
}

class SupportRemoteDataSourceImpl implements SupportRemoteDataSource {
  final Dio _dio;

  SupportRemoteDataSourceImpl(this._dio);

  @override
  Future<List<Map<String, dynamic>>> getLegalDocuments() async {
    try {
      final response = await _dio.get(
        '/legal-documents',
        queryParameters: {'page_id': 1, 'page_size': 10},
      );
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getHelpContents(String category) async {
    final response = await _dio.get(
      '/help_contents',
      queryParameters: {'page_id': 1, 'page_size': 10, 'category': category},
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  @override
  Future<List<Map<String, dynamic>>> getSupportMessages() async {
    final response = await _dio.get(
      '/support/messages',
      queryParameters: {'page_id': 1, 'page_size': 100},
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  @override
  Future<Map<String, dynamic>> sendSupportMessage(String body) async {
    final response = await _dio.post('/support/messages', data: {'body': body});
    return Map<String, dynamic>.from(response.data);
  }
}
