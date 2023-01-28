import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/place_item_res.dart';
import '../models/step_res.dart';
import '../utils/globals.dart';

class PlaceService {
  static Future<List<PlaceItemRes>> searchPlace(String keyWord) async {
    String url =
        "https://maps.googleapis.com/maps/api/place/textsearch/json?key=${Globals.API_KEY}&language=en&region=gh&query=${Uri.encodeQueryComponent(keyWord)}";

    print("search >>: " + url);
    var res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {

      return PlaceItemRes.fromJson(json.decode(res.body));
    } else {
      return [];
    }
  }

  static Future<List<PlaceItemRes>> searchPlace2(String keyWord) async {
    String url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?key=${Globals.API_KEY}&language=en&region=gh&input=${Uri.encodeQueryComponent(keyWord)}";

    print("search >>: " + url);
    var res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {

      return PlaceItemRes.fromJson2(json.decode(res.body));
    } else {
      return [];
    }
  }

  static Future<PlaceItemRes> searchCoordinates(String keyWord, PlaceItemRes place) async {
    // String url =
    //     "https://maps.googleapis.com/maps/api/place/autocomplete/json?key=${Globals.API_KEY}&language=en&region=gh&input=" +
    //         Uri.encodeQueryComponent(keyWord);

    String url = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=${Uri.encodeQueryComponent(keyWord)}&key=${Globals.API_KEY}&inputtype=textquery&fields=photos,formatted_address,name,rating,geometry&language=en&sensor=true&region=gh";;

    print("search >>: " + url);
    try{
      var res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {

        var result = json.decode(res.body);
        var location = result['candidates'][0]['geometry']['location'];
        List photos = result['candidates'][0]['photos'];
        List<String> photoRefs = [];
        for(var p in photos){
          photoRefs.add(p['photo_reference']);
        }


        return PlaceItemRes(result['candidates'][0]['name'], result['candidates'][0]['formatted_address'], location['lat'], location['lng'], photoRefs);
      } else {
        return PlaceItemRes("", "", 0.0, 0.0);
      }
    }catch(e){

      return PlaceItemRes("", "", 0.0, 0.0);
    }
  }



  static Future<String> getMyLocationName(double lat, double lng) async {
    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&sensor=true&key=${Globals.API_KEY}';

    var res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      print(data);
      var results = data['results'];
      var address = results[0]['formatted_address'];
      return address;
    }
    return '';
  }
}
