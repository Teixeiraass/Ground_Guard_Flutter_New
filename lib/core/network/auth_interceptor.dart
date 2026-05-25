import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;

  AuthInterceptor(this._dio);

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
    // Só tenta o refresh se for erro 401 e NÃO for na própria rota de refresh para evitar loop infinito
    if (err.response?.statusCode == 401 && !err.requestOptions.path.contains('/tokens/refresh')) {
      
      print('DEBUG_AUTH: Token expirado em ${err.requestOptions.path}. Tentando renovar...');
      
      final refreshToken = await SecureStorageService.getRefreshToken();
      
      if (refreshToken != null) {
        try {
          // Cria uma instância limpa para o refresh (sem este interceptor para não dar loop)
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

          // Salva o novo token
          await SecureStorageService.saveAccessToken(newAccessToken);

          // Atualiza o header da requisição original e repete
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

          // Resolve a requisição original com o resultado da nova tentativa
          return handler.resolve(clonedRequest);
          
        } catch (e) {
          print('DEBUG_AUTH: Falha crítica no Refresh Token: $e');
          // Se falhou o refresh, limpa tudo pois a sessão realmente expirou
          await SecureStorageService.clear();
        }
      } else {
        print('DEBUG_AUTH: Refresh Token não encontrado no storage.');
      }
    }
    
    // Se não entrou no IF ou se o try/catch falhou, passa o erro adiante
    return handler.next(err);
  }
}
