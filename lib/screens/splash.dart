import 'dart:async';
import 'home.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  @override
  SplashState createState() => new SplashState();
}

class SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: 1800), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MyHomePage()
        )
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    var introImage = Image.asset('images/splash.png');

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            introImage,
            Text(
              "Crunchy Bytes",
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}