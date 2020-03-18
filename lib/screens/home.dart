import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'article.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Center(
          child: Text(
            "HOME",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        child: StreamBuilder(
          stream: Firestore.instance
              .collection('news-articles')
              .orderBy("timestamp", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.none:
                return LinearProgressIndicator();
              default:
                return ListView.separated(
                  physics: BouncingScrollPhysics(),
                  separatorBuilder: (context, index) => Divider(
                    indent: 10,
                    endIndent: 10,
                    color: Colors.black26,
                  ),
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (_, index) => NewsTile(
                    data: snapshot.data.documents[index],
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}

class NewsTile extends StatelessWidget {
  NewsTile({this.data});

  final data;

  @override
  Widget build(BuildContext context) {
    Completer<Size> completer = Completer();
    Image image = Image.network(data['image-url']);
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
    String titleData, subTitleData, imageUrlData, timeData, dateData;

    titleData = data['title'];
    if ((data['sub-title'] != null) && (data['sub-title'] != '')) {
      subTitleData = data['sub-title'];
    } else {
      subTitleData = data[
          'body']; // Overflow attribute will not allow full body to appear.
    }
    imageUrlData = data['image-url'];
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
                child: CachedNetworkImage(
                  imageUrl: imageUrlData,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(
                    Icons.broken_image,
                    size: 40,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticlePage(data: data),
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
    String titleData, subTitleData, imageUrlData, dateData;
    titleData = data['title'];
    if (data['sub-title'] != null && data['sub-title'] != '') {
      subTitleData = data['sub-title'];
    } else {
      subTitleData = data['body'];
      // Overflow attribute will not allow
      // full body to appear in subtitle.
    }

    imageUrlData = data['image-url'];
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
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imageUrlData,
                  placeholder: (context, url) => LinearProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(
                    Icons.broken_image,
                    size: 80,
                  ),
                ),
              ),
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
            ],
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArticlePage(data: data),
              ),
            );
          },
        ),
      ),
    );
  }
}
