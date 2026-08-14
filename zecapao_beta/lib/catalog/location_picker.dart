import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'core.dart';

class DeliveryPoint {
  final double latitude;
  final double longitude;
  const DeliveryPoint(this.latitude, this.longitude);
  String get label => '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
}

class DeliveryLocationPickerPage extends StatefulWidget {
  const DeliveryLocationPickerPage({super.key});

  @override
  State<DeliveryLocationPickerPage> createState() => _DeliveryLocationPickerPageState();
}

class _DeliveryLocationPickerPageState extends State<DeliveryLocationPickerPage> {
  static const valeDoCapao = LatLng(-12.6115, -41.4946);
  LatLng selected = valeDoCapao;
  GoogleMapController? controller;
  bool locating = false;
  String? message;

  @override
  void initState() {
    super.initState();
    _useCurrentLocation(initial: true);
  }

  Future<void> _useCurrentLocation({bool initial = false}) async {
    if (!initial) setState(() => locating = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => message = 'Ative a localização do celular ou marque o ponto manualmente.');
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() => message = 'Permissão de localização não concedida. Você pode marcar o ponto no mapa.');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final point = LatLng(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() {
        selected = point;
        message = null;
      });
      await controller?.animateCamera(CameraUpdate.newLatLngZoom(point, 17));
    } catch (_) {
      if (mounted) setState(() => message = 'Não conseguimos detectar o GPS. Marque o ponto manualmente.');
    } finally {
      if (mounted && !initial) setState(() => locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onde entregar?')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(target: valeDoCapao, zoom: 15),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (c) => controller = c,
            onTap: (p) => setState(() => selected = p),
            markers: {
              Marker(
                markerId: const MarkerId('delivery'),
                position: selected,
                draggable: true,
                onDragEnd: (p) => setState(() => selected = p),
              ),
            },
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 16,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 18)]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Marque o ponto exato', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(message ?? 'Toque no mapa ou arraste o marcador.', style: const TextStyle(color: brandMuted, fontSize: 12)),
              ]),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 96,
            child: FloatingActionButton.small(
              heroTag: 'gps',
              backgroundColor: Colors.white,
              foregroundColor: brandRed,
              onPressed: locating ? null : () => _useCurrentLocation(),
              child: locating ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.my_location_rounded),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 18,
            child: FilledButton.icon(
              onPressed: () => Navigator.pop(context, DeliveryPoint(selected.latitude, selected.longitude)),
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text('CONFIRMAR LOCAL DE ENTREGA'),
            ),
          ),
        ],
      ),
    );
  }
}
