import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'article.dart';

class MyOfflineHomePage extends StatefulWidget {
  @override
  _MyOfflineHomePageState createState() => _MyOfflineHomePageState();
}

class _MyOfflineHomePageState extends State<MyOfflineHomePage> {
  var cachedData = List();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => loopOnceAtStart(context));
  }

  Future<SharedPreferences> loopOnceAtStart(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  List reverse(Set<String> l) {
    List rl = [];
    List _l = l.toList();
    for (int i = _l.length - 1; i >= 0; i--) {
      rl.add(_l[i]);
    }

    return rl;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loopOnceAtStart(context),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          SharedPreferences prefs = snapshot.data;
          reverse(prefs.getKeys()).forEach((element) {
            List<String> prefResolve = prefs.getStringList(element);
            cachedData.add({
              "title": prefResolve[0],
              "sub-title": prefResolve[1],
              "body": prefResolve[2],
              "date": prefResolve[3],
              "time": prefResolve[4],
              "image-base64": prefResolve[5],
            });
          });
          return Scaffold(
            appBar: AppBar(
              // Here we take the value from the MyHomePage object that was created by
              // the App.build method, and use it to set our appbar title.
              title: Text(
                "SAVED",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3,
                ),
              ),
              backgroundColor: Colors.black,
            ),
            body: Container(
              child: ListView.separated(
                physics: BouncingScrollPhysics(),
                separatorBuilder: (context, index) => Divider(
                  indent: 10,
                  endIndent: 10,
                  color: Colors.black26,
                ),
                itemCount: cachedData.length,
                itemBuilder: (_, index) => NewsTile(
                  data: cachedData[index],
                ),
              ),
            ),
          );
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

class NewsTile extends StatelessWidget {
  NewsTile({this.data});

  final data;

  @override
  Widget build(BuildContext context) {
    Completer<Size> completer = Completer();
    Image image = Image.memory(base64Decode(data["image-base64"]));
    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo image, bool synchronousCall) {
          var myImage = image.image;
          Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
          completer.complete(size);
        },
      ),
    );
    return FutureBuilder(
      future: completer.future,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.width / snapshot.data.height <= 1.2) {
            return NewsTileSmall(data: data);
          } else {
            return NewsTileLarge(data: data);
          }
        } else {
          return Text("");
        }
      },
    );
  }
}

class NewsTileSmall extends StatelessWidget {
  NewsTileSmall({this.data});

  final data;

  @override
  Widget build(BuildContext context) {
    String titleData, subTitleData, dateData;
    Image imageData;

    titleData = data['title'];
    if ((data['sub-title'] != null) && (data['sub-title'] != '')) {
      subTitleData = data['sub-title'];
    } else {
      subTitleData = data[
          'body']; // Overflow attribute will not allow full body to appear.
    }
    imageData = Image.memory(base64Decode(data["image-base64"]));
    dateData = data['date'];

    return FlatButton(
      padding: EdgeInsets.all(13),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      dateData,
                      style: TextStyle(
                        color: Colors.black45,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Wrap(
                      children: <Widget>[
                        Text(
                          titleData,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(
                      subTitleData,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageData,
              ),
            )
          ],
        ),
      ),
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ArticlePage(data: data, offline: true),
          ),
        );
      },
    );
  }
}

class NewsTileLarge extends StatelessWidget {
  NewsTileLarge({this.data});

  final data;

  @override
  Widget build(BuildContext context) {
    String titleData, subTitleData, dateData;
    Image imageData;
    TextOverflow overflowType;
    titleData = data['title'];
    if (data['sub-title'] != null && data['sub-title'] != '') {
      subTitleData = data['sub-title'];
      overflowType = TextOverflow.visible;
    } else {
      subTitleData = data['body'];
      overflowType = TextOverflow.ellipsis;
      // Overflow attribute will not allow
      // full body to appear in subtitle.
    }
    imageData = Image.memory(base64Decode(data["image-base64"]));
    dateData = data['date'];

    return Container(
      padding: EdgeInsets.all(13),
      child: ButtonTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(0),
        child: FlatButton(
          child: Column(
            children: <Widget>[
              ClipRRect(
                  borderRadius: BorderRadius.circular(12), child: imageData),
              Container(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      dateData,
                      style: TextStyle(
                        color: Colors.black45,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      titleData,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      subTitleData,
                      overflow: overflowType,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ArticlePage(data: data, offline: true),
              ),
            );
          },
        ),
      ),
    );
  }
}
