import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:codigo6_maps/utils/map_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
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

  Future<Uint8List> getImageMarkerBytes(String path,
      {bool fromInternet = false, int width = 100}) async {
    late Uint8List bytes;
    if (fromInternet) {
      File file = await DefaultCacheManager().getSingleFile(path);
      bytes = await file.readAsBytes();
    } else {
      ByteData byteData = await rootBundle.load(path);
      bytes = byteData.buffer.asUint8List();
    }

    final codec = await ui.instantiateImageCodec(bytes, targetWidth: width);
    ui.FrameInfo frame = await codec.getNextFrame();
    ByteData? myByteData =
        await frame.image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List myBytes = myByteData!.buffer.asUint8List();

    return myBytes;
  }

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
        onTap: (LatLng position) async {
          Marker marker = Marker(
            markerId: MarkerId(myMarkers.length.toString()),
            position: position,
            // icon: BitmapDescriptor.defaultMarkerWithHue(
            //     BitmapDescriptor.hueOrange),
            // icon: await BitmapDescriptor.fromAssetImage(
            //   ImageConfiguration(),
            //   "assets/images/location.png",
            // ),
            icon: BitmapDescriptor.fromBytes(
              await getImageMarkerBytes(
                "https://cdn-icons-png.flaticon.com/512/1673/1673219.png",
                fromInternet: true,
                width: 140,
              ),
            ),
            rotation: 0,
            draggable: true,
            onDrag: (LatLng newPosition) {
              print(newPosition);
            },
          );
          myMarkers.add(marker);
          setState(() {});
        },
      ),
    );
  }
}
