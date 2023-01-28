import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../blocs/place_bloc.dart';
import '../models/place_item_res.dart';
import '../widgets/loading_dialog.dart';




class RidePickerPage extends StatefulWidget {
  final String selectedAddress;
  final Function(PlaceItemRes, bool) onSelected;
  final bool _isFromAddress;

  RidePickerPage(this.selectedAddress, this.onSelected, this._isFromAddress);

  @override
  _RidePickerPageState createState() => _RidePickerPageState();
}

class _RidePickerPageState extends State<RidePickerPage> {
  var _addressController;
  PlaceBloc placeBloc = PlaceBloc();

  _RidePickerPageState();

  Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _cameraPosition = CameraPosition(
    target: LatLng(5.554359799999999, -0.1765333),
    zoom: 13.0,
  );

  // List<PlaceItemRes> places = [];

  @override
  void initState() {
    _addressController = TextEditingController(text: "");
    super.initState();
  }

  @override
  void dispose() {
    placeBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomSheet: Container(
        height: 100,
        decoration: const BoxDecoration(color: Colors.black),
        child: Column(),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _cameraPosition,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Positioned(
            left: 0,
            top: -10,
            right: 0,
            child: Column(
              children: <Widget>[
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 20, right: 20),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                            color: Color(0x88999999),
                            offset: Offset(0, 5),
                            blurRadius: 5.0)
                      ],
                    ),
                    child: Column(
                      children: <Widget>[
                        TextField(
                          autofocus: true,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              fillColor: Color(0xfff3f3f4),
                              filled: true,
                              hintText: 'search place'),
                          controller: _addressController,
                          textInputAction: TextInputAction.search,
                          onChanged: (str) {
                            if (str.length == 0) {
                              // places.clear();
                              return;
                            }

                            if (str.length >= 2) placeBloc.searchPlace2(str);
                          },
                          onSubmitted: (fullSearch) {
                            // places.clear();
                            placeBloc.searchPlace2(fullSearch);
                          },
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: StreamBuilder(
                    stream: placeBloc.placeStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data == "start") {
                          return Container(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),);
                        }

                        if (snapshot.data == "timeout") {
                          return Container(
                              child: const Center(
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                    'Oops! looks like we have internet connection problem here. retrying...'),
                              ),
                            ),
                          ));
                        }

                        List<PlaceItemRes> places = snapshot.data;


                        if (places.isEmpty) {
                          return Container(
                              child: Center(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                    'We could not find "${_addressController.text}", please try making location more specific'),
                              ),
                            ),
                          ),);
                        }

                        return Container(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: ListView.separated(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color(0x88999999),
                                        offset: Offset(0, 5),
                                        blurRadius: 5.0)
                                  ],
                                ),
                                child: ListTile(
                                  leading: const Icon(Icons.location_searching),
                                  title: Text(
                                    places.elementAt(index).name,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  subtitle: places.elementAt(index).address ==
                                          null
                                      ? const Text('')
                                      : Text(places.elementAt(index).address),
                                  onTap: ()async {

                                    LoadingDialog.showLoadingDialog(context, "Loading...");
                                   PlaceItemRes p = await placeBloc
                                        .searchCoordinates(places.elementAt(index).address,
                                        places.elementAt(index));

                                    LoadingDialog.hideLoadingDialog(context);

                                    Navigator.of(context).pop();
                                    widget.onSelected(p, widget._isFromAddress);
                                  },
                                ),
                              );
                            },
                            separatorBuilder: (context, index) => const Divider(
                              height: 2,
                              color: Colors.grey,
                            ),
                            itemCount: places.length,
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
