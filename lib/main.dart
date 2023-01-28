import 'package:flutter/material.dart';
import 'package:google_map_app/pages/details.dart';
import 'package:google_map_app/pages/home.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {

  Key key = UniqueKey();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Google Map App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) =>  MyHomePage(title: 'Welcome',),
          '/details': (context) => DetailsPage()
        },
      ),
    );;
  }
}


