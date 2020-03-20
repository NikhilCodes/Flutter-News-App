import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crunchy_bytes/screens/offline_home.dart';
import 'package:crypto/crypto.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:network_image_to_byte/network_image_to_byte.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class ArticlePage extends StatefulWidget {
  ArticlePage({this.data, this.offline});

  final data, offline;

  @override
  State<StatefulWidget> createState() {
    return _ArticlePageState(data: data, offline: offline);
  }
}

class _ArticlePageState extends State<ArticlePage>
    with SingleTickerProviderStateMixin {
  _ArticlePageState({this.data, this.offline});

  final data, offline;

  double lineLength = 0;

  Widget makeOfflineIcon = Icon(Icons.file_download);
  AnimationController _controller;
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
      value: 1,
    );
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => loopOnceAtStart(context));
  }

  Future<void> loopOnceAtStart(BuildContext context) async {
    prefs = await SharedPreferences.getInstance();
    if (offline == true) {
      setState(() {
        makeOfflineIcon = Icon(Icons.delete_outline);
      });
    } else if (prefs.containsKey(generateMd5(data['title']))) {
      setState(() {
        makeOfflineIcon = Icon(Icons.offline_pin);
      });
    }

    await _controller.forward();
    await _controller.reverse();
    setState(() {
      lineLength = MediaQuery.of(context).size.width * 0.3;
    });
  }

  String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String titleData, subTitleData, imageUrlData, bodyData;
    Widget imageWidget;
    List<String> dateAndTimeData;
    titleData = data['title'];
    if (data['sub-title'] != null) {
      subTitleData = data['sub-title'];
    } else {
      subTitleData = "";
      // allow full body to appear.
    }
    imageUrlData = data['image-url'] ?? '';
    bodyData = data['body'];
    dateAndTimeData = <String>[
      data['date'],
      data['time'],
    ];

    if (offline == true) {
      imageWidget = Hero(
        tag: generateMd5(titleData + "offline"),
        child: FadeInImage(
          placeholder: Image.asset('images/comingsoon-square.png').image,
          image: Image.memory(base64Decode(data["image-base64"])).image,
          fadeInDuration: Duration(milliseconds: 100),
          fadeInCurve: Curves.easeIn,
        ),
      );
    } else {
      imageWidget = Hero(
        tag: generateMd5(titleData),
        child: CachedNetworkImage(
          imageUrl: imageUrlData,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(
            Icons.broken_image,
            size: 40,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "ARTICLE",
          style: TextStyle(letterSpacing: 3),
        ),
        leading: Padding(
          padding: EdgeInsets.only(left: 20),
          child: GestureDetector(
            child: Icon(Icons.arrow_back_ios),
            onTap: () {
              if (offline == true) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyOfflineHomePage(),
                  ),
                );
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: GestureDetector(
              child: makeOfflineIcon,
              onTap: () async {
                if (offline == true) {
                  // REMOVAL BUTTON FUNCTION
                  setState(() {
                    prefs.remove(generateMd5(titleData));
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyOfflineHomePage(),
                      ),
                    );
                  });
                  return;
                }
                setState(() {
                  makeOfflineIcon = AspectRatio(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                    aspectRatio: 1,
                  );
                });
                if (prefs.containsKey(generateMd5(data['title']))) return;

                Uint8List base64imgData =
                    await networkImageToByte(imageUrlData);
                String base64string = base64Encode(base64imgData);
                prefs.setStringList("${generateMd5(titleData)}", [
                  titleData,
                  subTitleData,
                  bodyData,
                  dateAndTimeData[0], // Date
                  dateAndTimeData[1], // Time
                  base64string
                ]);
                setState(() {
                  makeOfflineIcon = Icon(Icons.offline_pin);
                });
              },
            ),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(13, 13, 13, 8),
            child: Text(
              titleData,
              style: TextStyle(
                fontFamily: 'Times New Roman',
                fontSize: 35,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 16, top: 10, bottom: 25),
            child: AnimatedContainer(
              curve: Curves.easeOut,
              duration: Duration(milliseconds: 700),
              height: 8,
              width: lineLength,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.indigoAccent],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(13, 0, 13, 10),
            child: Text(
              dateAndTimeData[0] + ' • ' + dateAndTimeData[1].toUpperCase(),
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(13, 0, 13, 10),
            child: Text(
              subTitleData,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontStyle: FontStyle.italic,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: imageWidget,
          ),
          Padding(
            padding: EdgeInsets.all(15),
            child: Text(
              bodyData,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 20,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10),
                  width: 40,
                  height: 2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1),
                    gradient: LinearGradient(
                      colors: [Colors.red.shade900, Colors.red.shade400],
                    ),
                  ),
                ),
                Text(
                  "X",
                  style: TextStyle(
                    color: Colors.yellow.shade800,
                    fontSize: 13,
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  width: 40,
                  height: 2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1),
                    gradient: LinearGradient(
                      colors: [Colors.red.shade400, Colors.red.shade900],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
