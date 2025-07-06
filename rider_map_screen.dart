import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/location_service.dart';
import '../utils/map_helper.dart';

class RiderMapScreen extends StatefulWidget {
  const RiderMapScreen({super.key});

  @override
  State<RiderMapScreen> createState() => _RiderMapScreenState();
}

class _RiderMapScreenState extends State<RiderMapScreen> {
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  List<LatLng> _pickupLocations = [];
  final LatLng _warehouseLocation = const LatLng(12.961115, 77.600000);

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _currentLocation = await LocationService.getCurrentLocation();
    _pickupLocations = MapHelper.generateNearbyLocations(_currentLocation!, 5);
    _setMarkers();
    _drawRoute();
    setState(() {});
  }

  void _setMarkers() {
    _markers.add(Marker(
      markerId: const MarkerId("rider"),
      position: _currentLocation!,
      infoWindow: const InfoWindow(title: "Your Location"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    ));
    for (int i = 0; i < _pickupLocations.length; i++) {
      _markers.add(Marker(
        markerId: MarkerId("pickup_$i"),
        position: _pickupLocations[i],
        infoWindow: InfoWindow(title: "Pickup #${i + 1}"),
      ));
    }
    _markers.add(Marker(
      markerId: const MarkerId("warehouse"),
      position: _warehouseLocation,
      infoWindow: const InfoWindow(title: "Warehouse"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    ));
  }

  void _drawRoute() {
    final List<LatLng> routePoints = [
      _currentLocation!,
      ..._pickupLocations,
      _warehouseLocation
    ];
    _polylines.add(Polyline(
      polylineId: const PolylineId("route"),
      points: routePoints,
      width: 5,
      color: Colors.blue,
    ));
  }

  Future<void> _openInGoogleMaps() async {
    final points = [_currentLocation!, ..._pickupLocations, _warehouseLocation];
    final url = Uri.parse(
        'https://www.google.com/maps/dir/${points.map((p) => '${p.latitude},${p.longitude}').join('/')}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rider Route Map")),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition:
                      CameraPosition(target: _currentLocation!, zoom: 14),
                  onMapCreated: (controller) => _mapController = controller,
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.navigation),
                    label: const Text("Navigate"),
                    onPressed: _openInGoogleMaps,
                  ),
                )
              ],
            ),
    );
  }
}
