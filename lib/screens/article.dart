import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class ArticlePage extends StatefulWidget {
  ArticlePage({this.data});

  final data;

  @override
  State<StatefulWidget> createState() {
    return _ArticlePageState(data: data);
  }
}

class _ArticlePageState extends State<ArticlePage>
    with SingleTickerProviderStateMixin {
  _ArticlePageState({this.data});

  final data;
  double lineLength = 0;
  AnimationController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
      value: 1,
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => loopOnce(context));
  }

  Future<void> loopOnce(BuildContext context) async {
    await _controller.forward();
    await _controller.reverse();
    setState(() {
      lineLength = MediaQuery.of(context).size.width * 0.3;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String titleData, subTitleData, imageUrlData, bodyData;
    List<String> dateAndTimeData;
    titleData = data['title'];
    if (data['sub-title'] != null) {
      subTitleData = data['sub-title'];
    } else {
      subTitleData = "";
      // allow full body to appear.
    }
    imageUrlData = data['image-url'];
    bodyData = data['body'];
    dateAndTimeData = <String>[
      data['date'],
      data['time'],
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Article"),
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
            child: CachedNetworkImage(
              imageUrl: imageUrlData,
              placeholder: (context, url) => LinearProgressIndicator(),
              errorWidget: (context, url, error) => Icon(
                Icons.broken_image,
                size: 100,
              ),
            ),
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
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: LinearGradient(
                      colors: [Colors.red.shade900, Colors.red.shade400],
                    ),
                  ),
                ),
                Text(
                  "X",
                  style: TextStyle(
                    color: Colors.yellow.shade800,
                    fontSize: 25,
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
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
