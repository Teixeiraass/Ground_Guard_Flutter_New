import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException("O servidor demorou demais para responder. Tente novamente.");
      case DioExceptionType.badResponse:
        return _handleError(error.response?.statusCode, error.response?.data);
      case DioExceptionType.cancel:
        return ApiException("A requisição foi cancelada.");
      case DioExceptionType.connectionError:
        return ApiException("Sem conexão com a internet ou servidor fora do ar.");
      default:
        return ApiException("Ocorreu um erro inesperado. Tente novamente mais tarde.");
    }
  }

  static ApiException _handleError(int? statusCode, dynamic error) {
    // Tenta extrair a mensagem de erro que vem do seu backend (ajuste conforme seu JSON de erro)
    String message = "Algo deu errado no servidor.";
    
    if (error is Map) {
      message = error['message'] ?? error['error'] ?? message;
    }

    switch (statusCode) {
      case 400:
        return ApiException(message, 400);
      case 401:
        return ApiException("Sessão expirada. Faça login novamente.", 401);
      case 403:
        return ApiException("Você não tem permissão para realizar esta ação.", 403);
      case 404:
        return ApiException("Recurso não encontrado.", 404);
      case 500:
        return ApiException("Erro interno no servidor. Tente em instantes.", 500);
      default:
        return ApiException(message, statusCode);
    }
  }

  @override
  String toString() => message;
}
