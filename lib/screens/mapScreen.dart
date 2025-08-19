import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/branchModel.dart';

class BranchMapScreen extends StatefulWidget {
  BranchMapScreen({super.key, required this.branch});
  BranchModel branch;

  @override
  State<BranchMapScreen> createState() => _BranchMapScreenState();
}

class _BranchMapScreenState extends State<BranchMapScreen> {
  late GoogleMapController mapController;
  Set<Marker> _buildMarkers() {
    return [].map((branch) {
      return Marker(
        markerId: MarkerId(widget.branch.id),
        position: LatLng(widget.branch.lat, widget.branch.lng),
        infoWindow: InfoWindow(
          title: widget.branch.name,
          snippet: "₹${widget.branch.pricePerHour}/hr",
        ),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Branches Map")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.branch.lat, widget.branch.lng),
          zoom: 12,
        ),
        markers: _buildMarkers(),
        onMapCreated: (controller) => mapController = controller,
      ),
    );
  }
}

class InteractiveMiniMap extends StatefulWidget {
  final double lat;
  final double lng;
  final String branchId;
  final String branchName;

  const InteractiveMiniMap({
    super.key,
    required this.lat,
    required this.lng,
    required this.branchId,
    required this.branchName,
  });

  @override
  State<InteractiveMiniMap> createState() => _InteractiveMiniMapState();
}

class _InteractiveMiniMapState extends State<InteractiveMiniMap> {
  late GoogleMapController _mapController;
  bool _isExpanded = false;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: _isExpanded ? 300 : 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[200],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.lat, widget.lng),
              zoom: 15,
            ),
            markers: {
              Marker(
                markerId: MarkerId(widget.branchId),
                position: LatLng(widget.lat, widget.lng),
                infoWindow: InfoWindow(title: widget.branchName),
              ),
            },
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: true,
            rotateGesturesEnabled: true,
            zoomGesturesEnabled: true,
            mapToolbarEnabled: false,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
          ),
        ),
      ),
    );
  }
}
