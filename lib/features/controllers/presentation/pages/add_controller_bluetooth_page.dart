import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ground_guard_app/core/routes/app_routes.dart';
import 'package:ground_guard_app/core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/ble_controller_service.dart';
import '../../data/models/ble_controller_payloads.dart';
import '../providers/controllers_provider.dart';

enum BluetoothSetupStep {
  search,
  connecting,
  wifiConfig,
  sendingConfig,
  registerApi,
  success,
}

class AddControllerBluetoothPage extends ConsumerStatefulWidget {
  const AddControllerBluetoothPage({super.key});

  @override
  ConsumerState<AddControllerBluetoothPage> createState() =>
      _AddControllerBluetoothPageState();
}

class _AddControllerBluetoothPageState
    extends ConsumerState<AddControllerBluetoothPage> {
  final BleControllerService _bleService = BleControllerService();
  BluetoothSetupStep _currentStep = BluetoothSetupStep.search;

  final TextEditingController _wifiSsidController = TextEditingController();
  final TextEditingController _wifiPasswordController = TextEditingController();
  final TextEditingController _controllerNameController =
      TextEditingController();

  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  final List<DiscoveredDevice> _discoveredDevices = [];

  DiscoveredDevice? _selectedBleDevice;
  BleControllerReadyPayload? _readyPayload;

  bool _isProcessing = false;
  String? _statusMessage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startPermissionAndScan();
  }

  @override
  void dispose() {
    _wifiSsidController.dispose();
    _wifiPasswordController.dispose();
    _controllerNameController.dispose();
    _scanSubscription?.cancel();
    _bleService.disconnectAndCleanup();
    super.dispose();
  }

  Future<void> _startPermissionAndScan() async {
    setState(() {
      _errorMessage = null;
      _discoveredDevices.clear();
      _statusMessage = 'Solicitando permissões...';
    });

    final hasPermission = await _bleService.requestPermissions();
    if (!hasPermission) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Permissão de Bluetooth negada. Por favor, permita o acesso ao Bluetooth nas configurações.';
      });
      return;
    }

    _startScan();
  }

  void _startScan() {
    setState(() {
      _errorMessage = null;
      _discoveredDevices.clear();
      _statusMessage = 'Procurando controladoras...';
    });

    _scanSubscription?.cancel();
    _scanSubscription = _bleService.scanForControllers().listen(
      (device) {
        if (!mounted) return;
        final index = _discoveredDevices.indexWhere((d) => d.id == device.id);
        if (index >= 0) {
          _discoveredDevices[index] = device;
        } else {
          _discoveredDevices.add(device);
        }
        setState(() {});
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _errorMessage =
              'Bluetooth desligado ou indisponível. Verifique as configurações do dispositivo.';
        });
      },
    );
  }

  void _showTriggerPairingDialog() {
    final deviceUidController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reiniciar pareamento Bluetooth'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Use quando a controladora já está ligada e conectada ao '
              'Wi-Fi, mas não aparece na busca Bluetooth. Informe o '
              'device_uid (MAC sem ":"), impresso na controladora ou '
              'visível no log Serial dela.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: deviceUidController,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                hintText: 'Ex.: AABBCCDDEEFF',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final deviceUid = deviceUidController.text.trim();
              if (deviceUid.isEmpty) return;
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(controllersProvider.notifier)
                    .triggerPairing(deviceUid);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Bluetooth reativado. Procurando controladora...',
                    ),
                  ),
                );
                _startScan();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceAll('Exception: ', '')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reativar'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectAndConnectDevice(DiscoveredDevice device) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _selectedBleDevice = device;
      _currentStep = BluetoothSetupStep.connecting;
      _statusMessage = 'Conectando à controladora...';
      _errorMessage = null;
    });

    try {
      await _bleService.connectToDevice(device.id);

      setState(() => _statusMessage = 'Obtendo dados da controladora...');
      final readyPayload = await _bleService.readReadyPayload(device.id);

      if (!mounted) return;

      setState(() {
        _readyPayload = readyPayload;
        _controllerNameController.text = readyPayload.deviceName;
        _isProcessing = false;
        _currentStep = BluetoothSetupStep.wifiConfig;
        _statusMessage = null;
      });
    } catch (e) {
      await _bleService.disconnectAndCleanup();
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
        _currentStep = BluetoothSetupStep.search;
        _errorMessage =
            'Falha ao conectar à controladora: ${e.toString().replaceAll('Exception: ', '')}';
      });
    }
  }

  Future<void> _submitWifiAndRegister() async {
    final wifiSsid = _wifiSsidController.text.trim();
    final wifiPassword = _wifiPasswordController.text;
    final controllerName = _controllerNameController.text.trim();

    if (wifiSsid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome da rede Wi-Fi (SSID)')),
      );
      return;
    }

    if (controllerName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome para a controladora')),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isProcessing = true;
      _currentStep = BluetoothSetupStep.sendingConfig;
      _statusMessage = 'Enviando configuração Wi-Fi...';
      _errorMessage = null;
    });

    try {
      if (_selectedBleDevice == null || _readyPayload == null) {
        throw Exception('Controladora não selecionada.');
      }

      // Envia credenciais Wi-Fi via BLE e aguarda "saved"
      await _bleService.sendWifiSetupAndConfirm(
        deviceId: _selectedBleDevice!.id,
        wifiSsid: wifiSsid,
        wifiPassword: wifiPassword,
      );

      // Limpa a senha da memória imediatamente por segurança
      _wifiPasswordController.clear();

      setState(() {
        _currentStep = BluetoothSetupStep.registerApi;
        _statusMessage = 'Registrando controladora...';
      });

      // Registra e clama no backend via API
      await ref
          .read(controllersProvider.notifier)
          .registerAndClaimBleController(
            deviceUid: _readyPayload!.deviceUid,
            name: controllerName,
            firmwareVersion: _readyPayload!.firmwareVersion,
            firmwareBuild: _readyPayload!.firmwareBuild,
          );

      // Desconecta do BLE com sucesso
      await _bleService.disconnectAndCleanup();

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
        _currentStep = BluetoothSetupStep.success;
        _statusMessage = null;
      });
    } catch (e) {
      await _bleService.disconnectAndCleanup();

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
        _currentStep = BluetoothSetupStep.wifiConfig;
        _errorMessage =
            'Erro no cadastro: ${e.toString().replaceAll('Exception: ', '')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F2),
      appBar: AppBar(
        title: const Text(
          'Nova Controladora',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D3520),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1D3520)),
        actions: [
          TextButton.icon(
            onPressed: () {
              _bleService.disconnectAndCleanup();
              ref.read(authProvider.notifier).logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
            icon: const Icon(
              Icons.logout_rounded,
              size: 18,
              color: Colors.redAccent,
            ),
            label: const Text(
              'Sair',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressHeader(),
              const SizedBox(height: 24),
              if (_errorMessage != null) _buildErrorBanner(),
              if (_statusMessage != null) _buildStatusBanner(),
              const SizedBox(height: 16),
              Expanded(child: _buildStepContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    int activeIndex = 0;
    switch (_currentStep) {
      case BluetoothSetupStep.search:
      case BluetoothSetupStep.connecting:
        activeIndex = 0;
        break;
      case BluetoothSetupStep.wifiConfig:
      case BluetoothSetupStep.sendingConfig:
        activeIndex = 1;
        break;
      case BluetoothSetupStep.registerApi:
      case BluetoothSetupStep.success:
        activeIndex = 2;
        break;
    }

    return Row(
      children: List.generate(3, (index) {
        final isActive = index <= activeIndex;
        return Expanded(
          child: Container(
            height: 6,
            margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _statusMessage!,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case BluetoothSetupStep.search:
        return _buildSearchStep();
      case BluetoothSetupStep.connecting:
        return _buildConnectingStep();
      case BluetoothSetupStep.wifiConfig:
      case BluetoothSetupStep.sendingConfig:
      case BluetoothSetupStep.registerApi:
        return _buildWifiConfigStep();
      case BluetoothSetupStep.success:
        return _buildSuccessStep();
    }
  }

  Widget _buildSearchStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Procurando Controladoras via BLE',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D3520),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ligue a caixa de comando Ground Guard e certifique-se de que o Bluetooth está ativo.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _isProcessing ? null : _showTriggerPairingDialog,
            icon: const Icon(
              Icons.settings_backup_restore_rounded,
              size: 18,
              color: AppColors.primary,
            ),
            label: const Text(
              'Controladora já ligada, mas não aparece?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'CONTROLADORAS ENCONTRADAS:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
            IconButton(
              onPressed: _isProcessing ? null : _startScan,
              icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _discoveredDevices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bluetooth_searching_rounded,
                        size: 52,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Procurando controladoras...',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _discoveredDevices.length,
                  itemBuilder: (context, index) {
                    final device = _discoveredDevices[index];
                    final displayName = device.name.isNotEmpty
                        ? device.name
                        : 'ground_guard_${device.id}';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.developer_board_rounded,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Sinal (RSSI): ${device.rssi} dBm'),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Colors.grey,
                        ),
                        onTap: _isProcessing
                            ? null
                            : () => _selectAndConnectDevice(device),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildConnectingStep() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            'Conectando à controladora...',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D3520),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Estabelecendo comunicação segura via BLE',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildWifiConfigStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuração de Wi-Fi e Nome',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D3520),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Device UID: ${_readyPayload?.deviceUid ?? "AABBCCDDEEFF"}',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _controllerNameController,
            enabled: !_isProcessing,
            decoration: InputDecoration(
              labelText: 'Nome da Controladora',
              prefixIcon: const Icon(Icons.edit_note_rounded),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _wifiSsidController,
            enabled: !_isProcessing,
            decoration: InputDecoration(
              labelText: 'Nome do Wi-Fi (SSID)',
              prefixIcon: const Icon(Icons.wifi_rounded),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _wifiPasswordController,
            enabled: !_isProcessing,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Senha do Wi-Fi',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _submitWifiAndRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Enviar e Cadastrar Controladora',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStep() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFD4E9D5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 64,
              color: Color(0xFF2D4029),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Controladora Cadastrada!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D3520),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sua caixa de comando foi vinculada com sucesso. Agora você pode adicionar sensores de solo.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                _bleService.disconnectAndCleanup();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.main,
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Ir para a Tela Inicial',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
