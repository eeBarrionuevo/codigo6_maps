import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:codigo6_maps/utils/map_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List data = [
    {
      "id": 1,
      "latitude": -16.402908,
      "longitude": -71.553949,
      "title": "Comisaria",
      "image": "https://cdn-icons-png.flaticon.com/512/3882/3882851.png",
    },
    {
      "id": 2,
      "latitude": -16.403330,
      "longitude": -71.550391,
      "title": "Bomberos",
      "image": "https://cdn-icons-png.flaticon.com/512/921/921079.png",
    },
    {
      "id": 3,
      "latitude": -16.405200,
      "longitude": -71.551901,
      "title": "Hospital",
      "image":
          "https://www.shareicon.net/data/512x512/2016/07/10/119238_hospital_512x512.png",
    },
  ];

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

  Set<Polyline> myPolylines = {};
  List<LatLng> _points = [];

  StreamSubscription<Position>? positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    getData();
    getCurrentPosition();
  }

  getData() {
    data.forEach((element) {
      getImageMarkerBytes(element["image"], fromInternet: true).then((value) {
        Marker marker = Marker(
          markerId: MarkerId(myMarkers.length.toString()),
          position: LatLng(element["latitude"], element["longitude"]),
          icon: BitmapDescriptor.fromBytes(value),
        );
        myMarkers.add(marker);
        setState(() {});
      });
    });
  }

  getCurrentPosition() async {
    Polyline route1 = Polyline(
      polylineId: const PolylineId("route1"),
      color: Colors.deepPurple,
      width: 3,
      points: _points,
    );
    myPolylines.add(route1);

    BitmapDescriptor myIcon = BitmapDescriptor.fromBytes(
      await getImageMarkerBytes(
        "https://freesvg.org/img/car_topview.png",
        fromInternet: true,
      ),
    );

    Position? positionTemp;

    positionStreamSubscription = Geolocator.getPositionStream().listen((event) {
      LatLng point = LatLng(event.latitude, event.longitude);
      _points.add(point);

      double rotation = 0;

      if (positionTemp != null) {
        rotation = Geolocator.bearingBetween(
          positionTemp!.latitude,
          positionTemp!.longitude,
          event.latitude,
          event.longitude,
        );
      }

      Marker indicator = Marker(
        markerId: MarkerId("IndicatorPosition"),
        position: point,
        icon: myIcon,
        rotation: rotation,
      );
      myMarkers.add(indicator);
      positionTemp = event;
      setState(() {});
    });
  }

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
  void dispose() {
    super.dispose();
    positionStreamSubscription!.cancel();
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
        myLocationEnabled: false,
        myLocationButtonEnabled: true,
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          controller.setMapStyle(json.encode(mapStyle));
        },
        zoomControlsEnabled: true,
        zoomGesturesEnabled: true,
        markers: myMarkers,
        polylines: myPolylines,
        // polygons: ,
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
