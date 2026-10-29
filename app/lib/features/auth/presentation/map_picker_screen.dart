import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';

class PickedAddress {
  const PickedAddress(this.address, this.latitude, this.longitude);

  final String address;
  final double latitude;
  final double longitude;
}

/// Xarita markazidagi nuqta manzilga aylantiriladi. Ochilganda foydalanuvchining joylashuviga o'tadi.
class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key, this.initial});

  final LatLng? initial;

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  static const _tashkent = LatLng(41.2995, 69.2401);

  final _controller = MapController();
  Timer? _debounce;
  late LatLng _center = widget.initial ?? _tashkent;
  String? _address;
  bool _resolving = true;
  int _requestId = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _scheduleResolve() {
    _debounce?.cancel();
    setState(() => _resolving = true);
    _debounce = Timer(const Duration(milliseconds: 700), _resolve);
  }

  Future<void> _resolve() async {
    final id = ++_requestId;
    final point = _center;
    String text = '';
    try {
      text = _format(await placemarkFromCoordinates(point.latitude, point.longitude));
    } catch (_) {}
    if (!mounted || id != _requestId) return;
    if (text.isEmpty) {
      text = '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
    }
    setState(() {
      _address = text;
      _resolving = false;
    });
  }

  String _format(List<Placemark> marks) {
    if (marks.isEmpty) return '';
    final p = marks.first;
    final seen = <String>{};
    final parts = <String>[];
    for (final raw in [p.locality ?? p.subAdministrativeArea, p.subLocality, p.street ?? p.thoroughfare]) {
      final v = raw?.trim() ?? '';
      if (v.isNotEmpty && seen.add(v.toLowerCase())) parts.add(v);
    }
    return parts.join(', ');
  }

  Future<void> _goToMyLocation({bool silent = false}) async {
    void notify() {
      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.mapPickerLocationFailed)));
      }
    }

    try {
      if (!await Geolocator.isLocationServiceEnabled()) return notify();
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return notify();
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 10)),
      );
      if (!mounted) return;
      _controller.move(LatLng(pos.latitude, pos.longitude), 17);
    } catch (_) {
      notify();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final canConfirm = !_resolving && _address != null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.mapPickerTitle)),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _controller,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: widget.initial == null ? 12 : 17,
                    minZoom: 5,
                    maxZoom: 19,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                    onMapReady: () {
                      _scheduleResolve();
                      if (widget.initial == null) _goToMyLocation(silent: true);
                    },
                    onPositionChanged: (camera, _) {
                      _center = camera.center;
                      _scheduleResolve();
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: AppConfig.applicationId,
                    ),
                    const SimpleAttributionWidget(source: Text('© OpenStreetMap')),
                  ],
                ),
                IgnorePointer(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 44),
                      child: Icon(Icons.location_on, size: 48, color: c.cta),
                    ),
                  ),
                ),
                Positioned(
                  right: AppSpacing.lg,
                  bottom: AppSpacing.lg,
                  child: FloatingActionButton.small(
                    heroTag: 'map-my-location',
                    tooltip: l10n.mapPickerMyLocation,
                    onPressed: _goToMyLocation,
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),
          Material(
            elevation: 8,
            color: Theme.of(context).colorScheme.surface,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.place_outlined, color: c.textSecondary),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            _resolving ? l10n.mapPickerLocating : (_address ?? ''),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: l10n.mapPickerConfirm,
                      isLoading: _resolving,
                      onPressed: canConfirm
                          ? () => Navigator.of(context).pop(
                                PickedAddress(_address!, _center.latitude, _center.longitude),
                              )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}