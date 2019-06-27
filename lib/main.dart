import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_utils/qr_utils.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';


void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Image _qrImg;
  String imageB64;
  TextEditingController _qrTextEditingController = TextEditingController();
  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();

  File _imageFile;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.teal,
          title: const Text('QR Scanner '),
        ),
        body: Container(
          padding: EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[


                TextFormField(
                  controller: _qrTextEditingController,
                  decoration: InputDecoration(
                      hintText: 'QR Content',
                      labelText: 'QR Content',
                      border: OutlineInputBorder()),
                ),
                SizedBox(
                  height: 12.0,
                ),
            Screenshot(
              controller: screenshotController,
              child:Center(
                  child: _qrImg != null
                      ? Container(
                    child: _qrImg,
                    width: 300.0,
                    height: 300.0,
                  )
                      : Image.asset(
                    'assets/ic_no_image.png',
                    width: 120.0,
                    height: 120.0,
                    fit: BoxFit.cover,
                  ),
                ),
      ),
                SizedBox(
                  height: 16.0,
                ),
                Center(
                  child: FlatButton(
                    color: Colors.teal,
                    onPressed: () => _generateQR(_qrTextEditingController.text),
                    child: Text(
                      'Generate QR',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _imageFile = null;
            screenshotController
                .capture(
                pixelRatio: 1.5
            )
                .then((File image) async {
              //print("Capture Done");
              setState(() {
                _imageFile = image;
                print(_imageFile.path);
                List<int> imageBytes = _imageFile.readAsBytesSync();
                imageB64 = base64Encode(imageBytes);
                if(_imageFile!=null)
                  Share.share(imageB64);
              });

            }).catchError((onError) {
              print(onError);
            });



          },
          tooltip: 'Increment',
          child: Icon(Icons.share),
          backgroundColor: Colors.teal,
        ), // This trailing comma makes auto-formatting nicer for build methods.
      )
      );
  }


  void _generateQR(String content) async {
    if (content.trim().length == 0) {
      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text('Please enter qr content')));
      setState(() {
        _qrImg = null;
      });
      return;
    }
    Image image;
    try {
      image = await QrUtils.generateQR(content);
    } on PlatformException {
      image = null;
    }
    setState(() {
      _qrImg = image;
    });
  }
}
