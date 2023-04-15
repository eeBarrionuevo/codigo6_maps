import 'dart:convert';

import 'package:codigo6_maps/utils/map_style.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Set<Marker> myMarkers = {
    Marker(
      markerId: MarkerId("mandarina1"),
      position: LatLng(-16.403337, -71.551929),
    ),
    Marker(
      markerId: MarkerId("mandarina2"),
      position: LatLng(-16.404640, -71.552101),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(-16.403472, -71.552446),
          zoom: 16,
        ),
        compassEnabled: true,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          controller.setMapStyle(json.encode(mapStyle));
        },
        zoomControlsEnabled: true,
        zoomGesturesEnabled: true,
        markers: myMarkers,
        onTap: (LatLng position) {
          Marker marker = Marker(
            markerId: MarkerId(myMarkers.length.toString()),
            position: position,
          );
          myMarkers.add(marker);
          setState(() {});
        },
      ),
    );
  }
}
