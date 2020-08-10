import 'package:flutter/material.dart';

import 'CharView.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Scaffold(
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text("char"),
          ),
          body: Container(
            height: 205,
            width: double.infinity,
          child: ChartViewGroup([19, 16, 13, 12, 10, 4, 6, 5, 6, 6, 8]),
        )

    ),);
  }
}


