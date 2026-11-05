import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../../components/adaptive_dropdown.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../controllers/data/models/controller_device_model.dart';
import '../../../controllers/presentation/providers/controllers_provider.dart';
import '../../../devices/data/models/device_model.dart';
import '../../../devices/presentation/providers/devices_provider.dart';
import '../../../soil_health/data/soil_health_model.dart';
import '../../../soil_health/presentation/soil_health_provider.dart';
import '../../../soil_health/presentation/soil_health_ui.dart';

const _osmTiles = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const _satelliteTiles =
    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
const _userAgentPackage = 'com.groundguard.app';
const _brazilCenter = LatLng(-14.235, -51.925);

/// Real sensor positions, set by the user (tap on the map or "use my
/// location" while standing next to the sensor) and stored in the API.
class MonitoringPage extends ConsumerStatefulWidget {
  const MonitoringPage({super.key});

  @override
  ConsumerState<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends ConsumerState<MonitoringPage> {
  final _mapController = MapController();
  bool _satellite = true;
  bool _userMovedMap = false;
  bool _locating = false;
  bool _saving = false;
  DeviceModel? _placing;
  LatLng? _myLocation;

  @override
  void initState() {
    super.initState();
    _centerOnApproximateLocation();
  }

  // No permission needed: IP-based city-level position, only used when no
  // sensor has been placed yet so the map doesn't open on the whole country.
  Future<void> _centerOnApproximateLocation() async {
    try {
      final response = await Dio().get(
        'https://ipwho.is/',
        options: Options(receiveTimeout: const Duration(seconds: 5)),
      );
      final data = Map<String, dynamic>.from(response.data);
      if (data['success'] != true) return;
      final lat = (data['latitude'] as num?)?.toDouble();
      final lng = (data['longitude'] as num?)?.toDouble();
      if (lat == null || lng == null || !mounted || _userMovedMap) return;
      if (_locatedDevices().isNotEmpty) return;
      _mapController.move(LatLng(lat, lng), 13);
    } catch (_) {
      // Stays on the default view.
    }
  }

  List<DeviceModel> _locatedDevices() =>
      (ref.read(devicesProvider).valueOrNull ?? const <DeviceModel>[])
          .where((d) => d.hasLocation)
          .toList();

  void _fitAll() {
    final points = [
      for (final d in _locatedDevices()) LatLng(d.latitude!, d.longitude!),
    ];
    if (points.isEmpty) return;
    if (points.length == 1) {
      _mapController.move(points.first, 18);
      return;
    }
    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: points,
        padding: const EdgeInsets.fromLTRB(60, 140, 60, 260),
        maxZoom: 19,
      ),
    );
  }

  Future<LatLng?> _currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      _snack('Ative a localização do celular para usar este recurso.');
      return null;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _snack(
        'Permita o acesso à localização nos ajustes do celular para usar este recurso.',
      );
      return null;
    }

    if (mounted) setState(() => _locating = true);
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      _snack('Não foi possível obter sua localização. Tente de novo.');
      return null;
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _goToMyLocation() async {
    final position = await _currentPosition();
    if (position == null || !mounted) return;
    setState(() => _myLocation = position);
    _mapController.move(position, 18);
  }

  Future<void> _placeAt(LatLng point) async {
    final device = _placing;
    if (device == null || _saving) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(devicesProvider.notifier)
          .setLocation(device.uuid, point.latitude, point.longitude);
      if (!mounted) return;
      setState(() => _placing = null);
      _snack('"${device.name}" posicionado no mapa.');
    } catch (e) {
      _snack('Não foi possível salvar a posição: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _placeAtMyLocation() async {
    final position = await _currentPosition();
    if (position == null) return;
    _mapController.move(position, 19);
    await _placeAt(position);
  }

  void _startPlacing(DeviceModel device) {
    setState(() => _placing = device);
    if (device.hasLocation) {
      _mapController.move(LatLng(device.latitude!, device.longitude!), 19);
    }
  }

  Future<void> _removeFromMap(DeviceModel device) async {
    try {
      await ref.read(devicesProvider.notifier).clearLocation(device.uuid);
      _snack('"${device.name}" removido do mapa.');
    } catch (e) {
      _snack('Não foi possível remover: $e');
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final controllersAsync = ref.watch(controllersProvider);
    final selectedController = ref.watch(selectedControllerProvider);
    final devicesAsync = ref.watch(devicesProvider);
    final health = ref.watch(soilHealthProvider).valueOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F2),
      body: Column(
        children: [
          _buildHeader(controllersAsync, selectedController),
          Expanded(
            child: selectedController == null
                ? const _CenteredMessage(
                    icon: Icons.developer_board_off_rounded,
                    title: 'Nenhuma controladora',
                    text:
                        'Cadastre uma controladora para ver seus sensores no mapa.',
                  )
                : devicesAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                    error: (err, _) => _CenteredMessage(
                      icon: Icons.cloud_off_rounded,
                      title: 'Erro ao carregar sensores',
                      text: '$err',
                    ),
                    data: (devices) =>
                        _buildMap(selectedController.uuid, devices, health),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(
    String controllerUuid,
    List<DeviceModel> devices,
    SoilHealthModel? health,
  ) {
    final located = devices.where((d) => d.hasLocation).toList();
    final points = [for (final d in located) LatLng(d.latitude!, d.longitude!)];

    return Stack(
      children: [
        FlutterMap(
          // A new controller gets a fresh initial camera on its own sensors.
          key: ValueKey(controllerUuid),
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _brazilCenter,
            initialZoom: 4,
            initialCameraFit: points.isEmpty
                ? null
                : CameraFit.coordinates(
                    coordinates: points,
                    padding: const EdgeInsets.fromLTRB(60, 140, 60, 260),
                    maxZoom: 18,
                  ),
            maxZoom: 20,
            minZoom: 3,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            onPositionChanged: (_, hasGesture) {
              if (hasGesture) _userMovedMap = true;
            },
            onTap: (_, point) {
              if (_placing != null) _placeAt(point);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: _satellite ? _satelliteTiles : _osmTiles,
              maxNativeZoom: _satellite ? 18 : 19,
              userAgentPackageName: _userAgentPackage,
            ),
            MarkerLayer(
              markers: [
                if (_myLocation != null)
                  Marker(
                    point: _myLocation!,
                    width: 22,
                    height: 22,
                    child: const _MyLocationDot(),
                  ),
                for (final device in located)
                  Marker(
                    point: LatLng(device.latitude!, device.longitude!),
                    width: 72,
                    height: 72,
                    alignment: Alignment.topCenter,
                    child: _SensorPin(
                      device: device,
                      sensorHealth: health?.sensor(device.uuid),
                      highlighted: _placing?.uuid == device.uuid,
                      onTap: () => _showDeviceSheet(device, health),
                    ),
                  ),
              ],
            ),
          ],
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Column(
            children: [
              _MapButton(
                icon: _satellite
                    ? Icons.map_outlined
                    : Icons.satellite_alt_rounded,
                tooltip: _satellite ? 'Mapa' : 'Satélite',
                onTap: () => setState(() => _satellite = !_satellite),
              ),
              const SizedBox(height: 10),
              _MapButton(
                icon: Icons.my_location_rounded,
                tooltip: 'Minha localização',
                loading: _locating && _placing == null,
                onTap: _goToMyLocation,
              ),
              if (located.isNotEmpty) ...[
                const SizedBox(height: 10),
                _MapButton(
                  icon: Icons.fit_screen_rounded,
                  tooltip: 'Ver todos os sensores',
                  onTap: _fitAll,
                ),
              ],
            ],
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: AppSpacing.bottomNavClearance - 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Attribution(satellite: _satellite),
              const SizedBox(height: 6),
              _placing != null
                  ? _PlacingPanel(
                      device: _placing!,
                      saving: _saving,
                      locating: _locating,
                      onUseMyLocation: _placeAtMyLocation,
                      onCancel: () => setState(() => _placing = null),
                    )
                  : _SummaryPanel(
                      devices: devices,
                      onPlace: () => _showPlaceSheet(devices),
                      onAddSensor: () => Navigator.pushNamed(
                        context,
                        AppRoutes.addDeviceQrCode,
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPlaceSheet(List<DeviceModel> devices) {
    final sorted = [...devices]
      ..sort((a, b) {
        if (a.hasLocation != b.hasLocation) return a.hasLocation ? 1 : -1;
        return a.name.compareTo(b.name);
      });

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 24, 24, 4),
                child: Text(
                  'Qual sensor você quer posicionar?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D3520),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Text(
                  'Dica: vá até o sensor e use "Minha localização" para marcar o ponto exato.',
                  style: TextStyle(fontSize: 13, color: AppColors.outline),
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final device in sorted)
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        leading: Icon(
                          device.hasLocation
                              ? Icons.location_on_rounded
                              : Icons.add_location_alt_outlined,
                          color: device.hasLocation
                              ? AppColors.primary
                              : AppColors.outline,
                        ),
                        title: Text(device.name),
                        subtitle: Text(
                          device.hasLocation
                              ? 'Já está no mapa'
                              : 'Sem posição',
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _startPlacing(device);
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeviceSheet(DeviceModel device, SoilHealthModel? health) {
    final sensorHealth = health?.sensor(device.uuid);
    final state = sensorHealth?.state ?? _fallbackState(device);
    final color = sensorStateColor(state);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(sensorStateIcon(state), color: color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D3520),
                          ),
                        ),
                        Text(
                          sensorStateLabel(state),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (device.soilMoisture != null && device.sensorOk != false)
                    Text(
                      '${device.soilMoisture}%',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D3520),
                      ),
                    ),
                ],
              ),
              if (sensorHealth?.timeInRange24h != null) ...[
                const SizedBox(height: 12),
                Text(
                  '${sensorHealth!.timeInRange24h}% do tempo na faixa ideal '
                  '(${sensorHealth.idealMin}–${sensorHealth.idealMax}%) nas últimas 24h',
                  style: const TextStyle(
                    color: AppColors.outline,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _removeFromMap(device);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.wrong_location_outlined),
                      label: const Text('Remover'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _startPlacing(device);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.open_with_rounded),
                      label: const Text('Mover'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    AsyncValue<List<ControllerDeviceModel>> controllersAsync,
    ControllerDeviceModel? selectedController,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Icon(Icons.developer_board_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MAPA DOS SENSORES',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    selectedController?.name ?? 'Nenhuma controladora',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1D3520),
                    ),
                  ),
                ],
              ),
            ),
            controllersAsync.when(
              data: (controllers) => AdaptiveDropdown(
                value: selectedController?.uuid,
                title: 'Selecione a controladora',
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primary,
                ),
                itemTextStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
                padding: EdgeInsets.zero,
                itemMaxWidth: 120,
                items: controllers
                    .map(
                      (c) => AdaptiveDropdownItem(value: c.uuid, label: c.name),
                    )
                    .toList(),
                onChanged: (uuid) {
                  if (uuid == null) return;
                  final newlySelected = controllers
                      .where((c) => c.uuid == uuid)
                      .firstOrNull;
                  if (newlySelected == null) return;
                  setState(() {
                    _placing = null;
                    _userMovedMap = false;
                  });
                  ref.read(selectedControllerProvider.notifier).state =
                      newlySelected;
                },
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

String _fallbackState(DeviceModel device) {
  if (device.sensorOk == false) return 'FAULT';
  if (!device.isOnline) return 'OFFLINE';
  final m = device.soilMoisture;
  if (m == null) return 'NO_DATA';
  if (m < 35) return 'DRY';
  if (m > 80) return 'WET';
  return 'OK';
}

class _SensorPin extends StatelessWidget {
  final DeviceModel device;
  final SensorHealthModel? sensorHealth;
  final bool highlighted;
  final VoidCallback onTap;

  const _SensorPin({
    required this.device,
    required this.sensorHealth,
    required this.highlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final state = sensorHealth?.state ?? _fallbackState(device);
    final color = sensorStateColor(state);
    final showValue =
        device.soilMoisture != null &&
        (state == 'OK' || state == 'DRY' || state == 'WET');

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: highlighted ? 52 : 46,
            height: highlighted ? 52 : 46,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: showValue
                ? Text(
                    '${device.soilMoisture}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  )
                : Icon(sensorStateIcon(state), color: Colors.white, size: 20),
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              device.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D3520),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyLocationDot extends StatelessWidget {
  const _MyLocationDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E88E5),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 4,
          ),
        ],
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool loading;

  const _MapButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 3,
        shadowColor: Colors.black26,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: loading ? null : onTap,
          child: SizedBox(
            width: 46,
            height: 46,
            child: loading
                ? const Padding(
                    padding: EdgeInsets.all(13),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Icon(icon, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

class _Attribution extends StatelessWidget {
  final bool satellite;

  const _Attribution({required this.satellite});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        satellite
            ? 'Imagens © Esri, Maxar, Earthstar Geographics'
            : '© OpenStreetMap',
        style: const TextStyle(fontSize: 10, color: Color(0xFF424840)),
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  final Widget child;

  const _PanelCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  final List<DeviceModel> devices;
  final VoidCallback onPlace;
  final VoidCallback onAddSensor;

  const _SummaryPanel({
    required this.devices,
    required this.onPlace,
    required this.onAddSensor,
  });

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) {
      return _PanelCard(
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Nenhum sensor nesta controladora ainda.',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D3520),
                ),
              ),
            ),
            FilledButton(
              onPressed: onAddSensor,
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Adicionar'),
            ),
          ],
        ),
      );
    }

    final placed = devices.where((d) => d.hasLocation).length;
    final missing = devices.length - placed;

    return _PanelCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$placed de ${devices.length} no mapa',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D3520),
                  ),
                ),
                Text(
                  missing == 0
                      ? 'Toque em um sensor para ver detalhes.'
                      : missing == 1
                      ? '1 sensor ainda sem posição.'
                      : '$missing sensores ainda sem posição.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: onPlace,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.add_location_alt_rounded, size: 20),
            label: const Text('Posicionar'),
          ),
        ],
      ),
    );
  }
}

class _PlacingPanel extends StatelessWidget {
  final DeviceModel device;
  final bool saving;
  final bool locating;
  final VoidCallback onUseMyLocation;
  final VoidCallback onCancel;

  const _PlacingPanel({
    required this.device,
    required this.saving,
    required this.locating,
    required this.onUseMyLocation,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final busy = saving || locating;

    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.touch_app_rounded, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  saving
                      ? 'Salvando posição...'
                      : 'Toque no mapa onde fica "${device.name}"',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D3520),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: busy ? null : onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.outline,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: busy ? null : onUseMyLocation,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.my_location_rounded, size: 18),
                  label: const Text('Usar minha localização'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _CenteredMessage({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF1D3520),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
