import 'dart:async';

import '../models/place_item_res.dart';
import '../repository/place_service.dart';



class PlaceBloc {
  var _placeController = StreamController.broadcast();

  Stream get placeStream => _placeController.stream;

  void searchPlace(String keyword) {

    _placeController.sink.add("start");
    PlaceService.searchPlace(keyword).then((rs) {
      _placeController.sink.add(rs);
    }).catchError((err) {
      //sink stop
      _placeController.sink.add("timeout");
      print('Error in searching: $err');
    });
  }

  void searchPlace2(String keyword) {

    _placeController.sink.add("start");
    PlaceService.searchPlace2(keyword).then((rs) {
      _placeController.sink.add(rs);
    }).catchError((err) {
      //sink stop
      _placeController.sink.add("timeout");
      print('Error in searching: $err');
    });
  }

  Future<PlaceItemRes> searchCoordinates(
      String keyword, PlaceItemRes place) async {
    var p = await PlaceService.searchCoordinates(keyword, place);
    return p;
  }

  void dispose() {
    _placeController.close();
  }
}
