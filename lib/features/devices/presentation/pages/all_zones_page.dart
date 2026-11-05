import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/device_model.dart';
import '../providers/devices_provider.dart';
import '../../../home/presentation/widgets/garden_card.dart';

class AllZonesPage extends ConsumerWidget {
  const AllZonesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsync = ref.watch(devicesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F2),
      appBar: AppBar(
        title: const Text(
          'Zonas do Jardim',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D3520),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: devicesAsync.when(
          data: (devices) => GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.9,
            ),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final d = devices[index];
              return GardenCard(
                icon: Icons.grass,
                title: d.name,
                humidity: '${d.soilMoisture ?? "--"}% Umidade',
                humidityColor: const Color(0xFFE09B2D),
                enabled: d.status.toUpperCase() == 'ATIVO',
                iconBg: const Color(0xFFCDEBC2),
                isOnline: d.isOnline,
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Erro: $err')),
        ),
      ),
    );
  }
}
