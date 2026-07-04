import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final Future<void> Function()? onUnauthorized;

  AuthInterceptor(this._dio, {this.onUnauthorized});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorageService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 1. Detecta erro de falta de acesso (401 Unauthorized ou 403 Forbidden)
    final isUnauthorized = err.response?.statusCode == 401 || err.response?.statusCode == 403;
    final isRefreshRoute = err.requestOptions.path.contains('/tokens/refresh');

    if (isUnauthorized) {
      // Se o erro ocorreu na própria rota de refresh, a sessão expirou de vez
      if (isRefreshRoute) {
        print('DEBUG_AUTH: Falha definitiva no Refresh Token (401/403). Forçando logout...');
        await _forceLogout();
        return handler.next(err);
      }

      // Se não for na rota de refresh, tenta renovar o token
      print('DEBUG_AUTH: Token expirado em ${err.requestOptions.path}. Tentando renovar...');
      
      final refreshToken = await SecureStorageService.getRefreshToken();
      
      if (refreshToken != null) {
        try {
          // Instância limpa para o refresh
          final refreshDio = Dio(BaseOptions(
            baseUrl: _dio.options.baseUrl,
            contentType: 'application/json',
          ));

          final response = await refreshDio.post(
            '/tokens/refresh',
            data: {'refresh_token': refreshToken},
          );

          final newAccessToken = response.data['access_token'];
          print('DEBUG_AUTH: Novo token obtido com sucesso!');

          await SecureStorageService.saveAccessToken(newAccessToken);

          // Repete a requisição original
          final requestOptions = err.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          
          final clonedRequest = await _dio.request(
            requestOptions.path,
            options: Options(
              method: requestOptions.method,
              headers: requestOptions.headers,
            ),
            data: requestOptions.data,
            queryParameters: requestOptions.queryParameters,
          );

          return handler.resolve(clonedRequest);
          
        } catch (e) {
          print('DEBUG_AUTH: Erro durante tentativa de refresh: $e');
          await _forceLogout();
        }
      } else {
        print('DEBUG_AUTH: Refresh Token não encontrado. Forçando logout...');
        await _forceLogout();
      }
    }
    
    return handler.next(err);
  }

  Future<void> _forceLogout() async {
    await SecureStorageService.clear();
    if (onUnauthorized != null) {
      await onUnauthorized!();
    }
  }
}
