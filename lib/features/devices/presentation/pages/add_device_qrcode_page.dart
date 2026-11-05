import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ground_guard_app/components/adaptive_dropdown.dart';
import 'package:ground_guard_app/core/routes/app_routes.dart';
import '../../../controllers/presentation/providers/controllers_provider.dart';
import '../providers/devices_provider.dart';

class AddDeviceQrCodePage extends ConsumerStatefulWidget {
  const AddDeviceQrCodePage({super.key});

  @override
  ConsumerState<AddDeviceQrCodePage> createState() =>
      _AddDeviceQrCodePageState();
}

class _AddDeviceQrCodePageState extends ConsumerState<AddDeviceQrCodePage> {
  late MobileScannerController cameraController;
  final TextEditingController _manualCodeController = TextEditingController();
  final TextEditingController _deviceNameController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    _manualCodeController.dispose();
    _deviceNameController.dispose();
    super.dispose();
  }

  Future<void> _handleDeviceLink(String deviceId) async {
    if (_isProcessing) return;

    final selectedController = ref.read(selectedControllerProvider);
    if (selectedController == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cadastre uma Controladora antes de adicionar sensores.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.pushNamed(context, AppRoutes.addControllerBluetooth);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final linkedDevice = await ref
          .read(devicesProvider.notifier)
          .linkDevice(deviceId, controllerUuid: selectedController.uuid);
      if (mounted) {
        _showDeviceNameModal(linkedDevice.uuid);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao vincular: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleDeviceNaming(String deviceUuid, String name) async {
    try {
      await ref.read(devicesProvider.notifier).updateName(deviceUuid, name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sensor configurado com sucesso!')),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.main,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao definir nome: ${e.toString().replaceAll("Exception: ", "")}',
            ),
          ),
        );
      }
    }
  }

  void _showDeviceNameModal(String deviceId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          top: 32,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nome do Sensor',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF173518),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Dê um nome para identificar este ponto de monitoramento no solo (ex: Sensor Horta).',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _deviceNameController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Ex: Sensor Canteiro Central',
                filled: true,
                fillColor: const Color(0xFFF4F4EF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(
                  Icons.edit_note_rounded,
                  color: Color(0xFF173518),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final name = _deviceNameController.text.trim();
                if (name.isNotEmpty) {
                  Navigator.pop(context);
                  _handleDeviceNaming(deviceId, name);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF173518),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text(
                'Salvar e Continuar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showManualInputModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          top: 32,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Digitar código do Sensor',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF173518),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _manualCodeController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Ex: GG-SNS-XXXX',
                filled: true,
                fillColor: const Color(0xFFF4F4EF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(
                  Icons.qr_code_rounded,
                  color: Color(0xFF173518),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final code = _manualCodeController.text.trim();
                if (code.isNotEmpty) {
                  Navigator.pop(context);
                  _handleDeviceLink(code);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF173518),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text(
                'Confirmar Sensor',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanAreaSize = size.width * 0.7;
    const verticalOffset = -0.4;

    final controllersAsync = ref.watch(controllersProvider);
    final selectedController = ref.watch(selectedControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F4EF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF173518)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Adicionar Sensor (Solo)',
          style: TextStyle(
            color: Color(0xFF173518),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: cameraController,
            builder: (context, state, child) {
              return IconButton(
                icon: Icon(
                  state.torchState == TorchState.on
                      ? Icons.flashlight_off_rounded
                      : Icons.flashlight_on_rounded,
                  color: const Color(0xFF173518),
                ),
                onPressed: () => cameraController.toggleTorch(),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && !_isProcessing) {
                final code = barcodes.first.rawValue;
                if (code != null) {
                  _handleDeviceLink(code);
                }
              }
            },
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: ScannerOverlayPainter(
                  scanAreaSize: scanAreaSize,
                  verticalOffset: verticalOffset,
                ),
              ),
            ),
          ),

          // SELETOR DA CONTROLADORA PAI NO TOPO
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.developer_board_rounded,
                    color: Color(0xFF173518),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'VINCULAR À CONTROLADORA:',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          selectedController?.name ?? 'Nenhuma selecionada',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF173518),
                          ),
                        ),
                      ],
                    ),
                  ),
                  controllersAsync.when(
                    data: (controllers) {
                      if (controllers.isEmpty) {
                        return TextButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.addControllerBluetooth,
                          ),
                          child: const Text(
                            'Cadastrar',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF173518),
                            ),
                          ),
                        );
                      }
                      return AdaptiveDropdown(
                        value: selectedController?.uuid,
                        title: 'Selecione a controladora',
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF173518),
                        ),
                        itemTextStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF173518),
                        ),
                        padding: EdgeInsets.zero,
                        itemMaxWidth: 100,
                        items: controllers
                            .map(
                              (c) => AdaptiveDropdownItem(
                                value: c.uuid,
                                label: c.name,
                              ),
                            )
                            .toList(),
                        onChanged: (uuid) {
                          if (uuid != null) {
                            final newlySelected = controllers
                                .where((c) => c.uuid == uuid)
                                .firstOrNull;
                            if (newlySelected != null) {
                              ref
                                      .read(selectedControllerProvider.notifier)
                                      .state =
                                  newlySelected;
                            }
                          }
                        },
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Aponte para o QR Code do Sensor',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF173518),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Enquadre o código para associar o sensor à controladora escolhida.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (_isProcessing)
                  const CircularProgressIndicator(color: Colors.white)
                else
                  ElevatedButton.icon(
                    onPressed: _showManualInputModal,
                    icon: const Icon(Icons.keyboard_outlined, size: 20),
                    label: const Text('Digite o código manualmente'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D4029),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final double scanAreaSize;
  final double verticalOffset;
  ScannerOverlayPainter({
    required this.scanAreaSize,
    required this.verticalOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutRect = Rect.fromCenter(
      center: Offset(
        size.width / 2,
        size.height / 2 + (size.height / 2 * verticalOffset),
      ),
      width: scanAreaSize,
      height: scanAreaSize,
    );
    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(cutoutRect, const Radius.circular(40)),
      );
    final path = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );
    canvas.drawPath(path, Paint()..color = Colors.black.withOpacity(0.65));

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(cutoutRect, const Radius.circular(40)),
      paint,
    );

    final cornerPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    const cornerLength = 45.0;

    // Top Left
    canvas.drawPath(
      Path()
        ..moveTo(cutoutRect.left, cutoutRect.top + cornerLength)
        ..lineTo(cutoutRect.left, cutoutRect.top)
        ..lineTo(cutoutRect.left + cornerLength, cutoutRect.top),
      cornerPaint,
    );

    // Top Right
    canvas.drawPath(
      Path()
        ..moveTo(cutoutRect.right - cornerLength, cutoutRect.top)
        ..lineTo(cutoutRect.right, cutoutRect.top)
        ..lineTo(cutoutRect.right, cutoutRect.top + cornerLength),
      cornerPaint,
    );

    // Bottom Left
    canvas.drawPath(
      Path()
        ..moveTo(cutoutRect.left, cutoutRect.bottom - cornerLength)
        ..lineTo(cutoutRect.left, cutoutRect.bottom)
        ..lineTo(cutoutRect.left + cornerLength, cutoutRect.bottom),
      cornerPaint,
    );

    // Bottom Right
    canvas.drawPath(
      Path()
        ..moveTo(cutoutRect.right - cornerLength, cutoutRect.bottom)
        ..lineTo(cutoutRect.right, cutoutRect.bottom)
        ..lineTo(cutoutRect.right, cutoutRect.bottom - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
