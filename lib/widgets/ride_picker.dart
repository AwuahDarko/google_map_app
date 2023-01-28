import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/place_item_res.dart';
import '../pages/ride_picker_page.dart';

class RidePicker extends StatefulWidget {
  final Function(PlaceItemRes, bool) onDestinationSelected;
  final Function(PlaceItemRes) onLocationSelected;
  final String myLocationName;

  RidePicker(
      {required this.onDestinationSelected,
      required this.onLocationSelected,
      required this.myLocationName});

  _RidePickerState createState() => _RidePickerState();
}

class _RidePickerState extends State<RidePicker> {
//  final MapLocation mpLoc = MapLocation();
  PlaceItemRes? fromAddress;
  PlaceItemRes? toAddress;

  final ButtonStyle flatButtonStyle = TextButton.styleFrom(
    primary: Colors.black87,
    minimumSize: const Size(88, 36),
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(0)),
      ),
      child: Column(
        children: <Widget>[
          pickUpLocation(),
        ],
      ),
    );
  }

  Widget pickUpLocation() {
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          height: 50,
          child: TextButton(
            style: flatButtonStyle,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => RidePickerPage(fromAddress == null ? "" : fromAddress!.name, (place, isFrom) {
                        widget.onLocationSelected(place);
                        fromAddress = place;
                        setState(() {});
                      }, true),),);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.all(Radius.circular(0)),
              ),
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                alignment: AlignmentDirectional.centerStart,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(color: Colors.transparent),
                    child: Image.asset('assets/images/location.png'),
                  ),
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    padding: const EdgeInsets.only(left: 40.0, bottom: 0.0, top: 8.0),
                    child: Text(
                      fromAddress == null ? "Search location" : fromAddress!.name,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
