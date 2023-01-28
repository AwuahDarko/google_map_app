class PlaceItemRes {
  String name;
  String address;
  double lat;
  double lng;
  List<String>? photoRef;

  PlaceItemRes(this.name, this.address, this.lat, this.lng, [ this.photoRef ]);

  static List<PlaceItemRes> fromJson(Map<String, dynamic> json) {

    List<PlaceItemRes> rs = [];

    var results = json['results'] as List;
    for (var item in results) {
      var p = PlaceItemRes(
          item['name'],
          item['formatted_address'],
          item['geometry']['location']['lat'],
          item['geometry']['location']['lng']);

      rs.add(p);
    }
    return rs;
  }

  static List<PlaceItemRes> fromJson2(Map<String, dynamic> json) {
    print("parsing data");
    List<PlaceItemRes> rs = [];

    var results = json['predictions'] as List;
    for (var item in results) {
      var secondary = item['structured_formatting']['secondary_text'];
      var main = item['structured_formatting']['main_text'];
      var description = item['description'];
      var p = PlaceItemRes(
          main,
          description,
          0.0,
          0.0);

      rs.add(p);
    }
    return rs;
  }

  Map<String, dynamic> toMap(){
    return {
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng
    };
  }
}
