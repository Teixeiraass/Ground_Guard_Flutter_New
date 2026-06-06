import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ground_guard_app/core/routes/app_routes.dart';
import '../providers/devices_provider.dart';

class AddDeviceQrCodePage extends ConsumerStatefulWidget {
  const AddDeviceQrCodePage({super.key});

  @override
  ConsumerState<AddDeviceQrCodePage> createState() => _AddDeviceQrCodePageState();
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
    setState(() => _isProcessing = true);

    try {
      await ref.read(devicesProvider.notifier).linkDevice(deviceId);
      if (mounted) {
        _showDeviceNameModal(deviceId);
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

  Future<void> _handleDeviceNaming(String deviceId, String name) async {
    try {
      await ref.read(devicesProvider.notifier).updateName(deviceId, name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dispositivo configurado com sucesso!')),
        );
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao definir nome: ${e.toString()}')),
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
          top: 32, left: 24, right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nome do Dispositivo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF173518)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Dê um nome para identificar seu sensor (ex: Jardim Principal).',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _deviceNameController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Nome do dispositivo',
                filled: true,
                fillColor: const Color(0xFFF4F4EF),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.edit_note_rounded, color: Color(0xFF173518)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: const Text('Salvar e Continuar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
          top: 32, left: 24, right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Digitar código', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF173518))),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _manualCodeController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Ex: GG-XXXX-XXXX',
                filled: true,
                fillColor: const Color(0xFFF4F4EF),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.qr_code_rounded, color: Color(0xFF173518)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: const Text('Confirmar Dispositivo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F4EF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF173518)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Adicionar Dispositivo', style: TextStyle(color: Color(0xFF173518), fontWeight: FontWeight.bold)),
        actions: [
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: cameraController,
            builder: (context, state, child) {
              return IconButton(
                icon: Icon(
                  state.torchState == TorchState.on ? Icons.flashlight_off_rounded : Icons.flashlight_on_rounded,
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

          Positioned(
            bottom: 60, left: 24, right: 24,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Column(
                    children: [
                      Text('Aponte a câmera para o QR Code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF173518))),
                      SizedBox(height: 12),
                      Text('Enquadre o código dentro do quadrado acima.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.black54)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
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
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
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
  ScannerOverlayPainter({required this.scanAreaSize, required this.verticalOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 + (size.height / 2 * verticalOffset)),
      width: scanAreaSize, height: scanAreaSize,
    );
    final cutoutPath = Path()..addRRect(RRect.fromRectAndRadius(cutoutRect, const Radius.circular(40)));
    final path = Path.combine(PathOperation.difference, backgroundPath, cutoutPath);
    canvas.drawPath(path, Paint()..color = Colors.black.withOpacity(0.65));

    final paint = Paint()..color = Colors.white.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawRRect(RRect.fromRectAndRadius(cutoutRect, const Radius.circular(40)), paint);

    final cornerPaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 6;
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
