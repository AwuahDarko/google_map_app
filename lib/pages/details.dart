import 'package:flutter/material.dart';
import 'package:google_map_app/models/place_item_res.dart';


import '../models/photo_item.dart';
import '../utils/globals.dart';

class DetailsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {

   List<PhotoItem> _items = [];


  @override
  Widget build(BuildContext context) {
    Map arg = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    PlaceItemRes place = arg['PlaceItemRes'] as PlaceItemRes;

    List<String> it = place.photoRef ?? [];
    _items = [];
    for(String i in it){
      String url = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$i&key=${Globals.API_KEY}";
      _items.add(PhotoItem(url, ''));
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:  Text(place.name),
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.5,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  crossAxisCount: 3,
                ),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(_items[index].image),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20,),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 20,
              child: const Text('Place Description',style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
              ),),
            ),
            const SizedBox(height: 5,),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child:  Text("${place.address}\n${place.name}", maxLines: 10, ),
            )
          ],
        )
      ),
    );
  }
}
