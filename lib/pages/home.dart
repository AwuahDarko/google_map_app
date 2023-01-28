import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:location/location.dart';

import '../widgets/ride_picker.dart';
import '../models/place_item_res.dart';
import '../repository/place_service.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  Completer<GoogleMapController> _completer = Completer();

  Location _locationService = Location();
  late LatLng currentLocation;
  LatLng _center = LatLng(5.554359799999999, -0.1765333);
  late GoogleMapController controller;

  BitmapDescriptor? sourceIcon;
  BitmapDescriptor? destinationIcon;

  late PermissionStatus _permission;
  List<Marker> _markers = [];
  List<Polyline> routes = [];
  bool done = false;

  double _zoom = 10.0;

  String error = '';
  String myLocationName = "";
  bool isFirstRun = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();

    setSourceAndDestinationIcons();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        body: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: height * 0.85,
                  child: Stack(
                    children: <Widget>[
                      GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                          target: _center,
                          zoom: _zoom,
                        ),
                        onMapCreated: (GoogleMapController controller) {
                          _completer.complete(controller);
                        },
                        markers: Set<Marker>.of(_markers),
                        polylines: Set<Polyline>.of(routes),
                        compassEnabled: true,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        right: 0,
                        child: Column(
                          children: <Widget>[
                            AppBar(
                              backgroundColor: Colors.transparent,
                              elevation: 0.0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    padding: EdgeInsets.all(0.0),
                    color: Colors.white,
                    width: double.infinity,
                    height: height * 0.10,
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.only(top: 5, bottom: 5),
                          width: double.infinity,
                          height: 20.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const <Widget>[
                              Spacer(
                                flex: 1,
                              ),
                            ],
                          ),
                        ),
                        RidePicker(
                            onLocationSelected: onMyPlaceSelected,
                            onDestinationSelected: onPlaceSelected,
                            myLocationName: myLocationName),
                      ],
                    ))
              ],
            )));
  }

  void onPlaceSelected(PlaceItemRes place, bool fromAddress) {
    var mkId = fromAddress ? "from_address" : "to_address";
    _addMarker(mkId, place);
  }

  void onMyPlaceSelected(PlaceItemRes place) {
    setNewCameraPosition(LatLng(place.lat, place.lng));
    _addMyPlaceMarker('from_address', place);

    if (_markers[1].position.latitude != 0.0 && _markers[1].position.longitude != 0.0) {
      routes.clear();
      // addPolyline();
    }
  }

  void _addMyPlaceMarker(String mkId, PlaceItemRes place) async {
    // remove old
    Marker marker = Marker(
      markerId: MarkerId(mkId),
      draggable: true,
      position: LatLng(place.lat, place.lng),
      infoWindow: InfoWindow(
          title: place.name,
          snippet: place.address,
          onTap: () {
            Navigator.pushNamed(context, '/details', arguments: {'PlaceItemRes': place});
          }),
      icon: sourceIcon!,
    );

    setState(() {
      _markers[0] = marker;
    });
  }

  void _addMarker(String mkId, PlaceItemRes place) async {
    // remove old

    Marker marker = Marker(
        markerId: MarkerId(mkId),
        draggable: true,
        position: LatLng(place.lat, place.lng),
        infoWindow: InfoWindow(title: place.name, snippet: mkId),
        icon: destinationIcon!);

    setState(() {
      if (mkId == "from_address") {
        _markers[0] = marker;
      } else if (mkId == "to_address") {
        _markers[1] = marker;
      }
    });
  }

  void initPlatformState() async {
    await _locationService.changeSettings(accuracy: LocationAccuracy.high, interval: 1000);

    LocationData location;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      bool serviceStatus = await _locationService.serviceEnabled();

      if (serviceStatus) {
        _permission = await _locationService.requestPermission();

        if (_permission == PermissionStatus.granted) {
          location = await _locationService.getLocation();

          currentLocation = LatLng(location.latitude!, location.longitude!);

          _center = LatLng(currentLocation.latitude, currentLocation.longitude);

          myLocationName = await PlaceService.getMyLocationName(currentLocation.latitude, currentLocation.longitude);

          if (mounted) {
            setState(() {
              setNewCameraPosition(_center);
              _markers[0] = Marker(
                  markerId: MarkerId('from_address'),
                  position: LatLng(location.latitude!, location.longitude!),
                  infoWindow: InfoWindow(
                    title: myLocationName,
                  ),
                  icon: sourceIcon!);

              // add drivers

              done = true;
            });
          }
        }
      } else {
        bool serviceStatusResult = await _locationService.requestService();

        if (serviceStatusResult) {
          initPlatformState();
        }
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = e.message!;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        error = e.message!;
      }
    }
  }

  void setNewCameraPosition(latLong) async {
    final CameraPosition position = CameraPosition(target: latLong, zoom: _zoom);

    controller = await _completer.future;

    controller.animateCamera(CameraUpdate.newCameraPosition(position));
  }

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 90), 'assets/images/multi-marker.png');

    destinationIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 1), 'assets/images/destination.png');

    setSourceAndDestinationDefaultMarkers();

    initPlatformState();
  }

  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
  }

  void setSourceAndDestinationDefaultMarkers() {
    _markers.add(Marker(
        markerId: MarkerId('from_address'),
        position: LatLng(0.0, 0.0),
        infoWindow: InfoWindow(title: 'Unnamed'),
        icon: sourceIcon!));

    _markers.add(Marker(
        rotation: 0.0,
        markerId: MarkerId('to_address'),
        position: LatLng(-50.0, 0.0),
        infoWindow: InfoWindow(title: "Destination"),
        icon: destinationIcon!));
  }

  void adjustCameraPosition() {
    if (_markers.length > 1) {
      List<LatLng> list = [];
      list.add(LatLng(_markers[0].position.latitude, _markers[0].position.longitude));

      list.add(LatLng(_markers[1].position.latitude, _markers[1].position.longitude));
      Future.delayed(Duration(milliseconds: 200),
          () => controller.animateCamera(CameraUpdate.newLatLngBounds(boundsFromLatLngList(list), 90)));
    }
  }
}
