class AppInitializer {
  static Future<void> initialize(Function(double, String) onProgress) async {

    await Future.delayed(const Duration(milliseconds: 500));
    onProgress(0.3, 'Carregando configurações...');

    await Future.delayed(const Duration(milliseconds: 500));
    onProgress(0.6, 'Validando sessão...');

    await Future.delayed(const Duration(milliseconds: 1000));
    onProgress(1.0, 'Finalizando...');
  }
}