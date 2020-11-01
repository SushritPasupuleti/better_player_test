import 'dart:async';
import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  BetterPlayerController _betterPlayerController;
  StreamController<bool> _fileVideoStreamController =
      StreamController.broadcast();
  bool _fileVideoShown = true;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  Future<BetterPlayerController> _setupFileVideoData() async {
    await _saveAssetVideoToFile();
    final directory = await getApplicationDocumentsDirectory();

    var dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.FILE,
      "${directory.path}/zawarudo.mp4",
    );
    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
          overlay: Scaffold(
        appBar: AppBar(
          title: new Text("Video Title"),
          elevation: 0.0,
          backgroundColor: const Color(0x00000000).withOpacity(0.5),
        ),
        backgroundColor: Colors.transparent,
      )),
      betterPlayerDataSource: dataSource,
    );

    _betterPlayerController.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.FINISHED) {
        print("Better player event: ${event.betterPlayerEventType}");
        ///_betterPlayerController.play();
      }
    });
    return _betterPlayerController;
  }

  Future _saveAssetVideoToFile() async {
    var content = await rootBundle.load("assets/zawarudo.mp4");
    final directory = await getApplicationDocumentsDirectory();
    var file = File("${directory.path}/zawarudo.mp4");
    file.writeAsBytesSync(content.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      // Padding(
      //   padding: EdgeInsets.all(8),
      //   child: Text("This is example default video. This video is loaded from"
      //       " URL. Subtitles are loaded from file."),
      // ),
      _buildFileVideo()
    ]);
  }

  Widget _buildShowFileVideoButton() {
    return Column(children: [
      RaisedButton(
        child: Text("Show video from file"),
        onPressed: () {
          _fileVideoShown = !_fileVideoShown;
          _fileVideoStreamController.add(_fileVideoShown);
        },
      ),
      _buildFileVideo()
    ]);
  }

  Widget _buildFileVideo() {
    // return
    // StreamBuilder<bool>(
    //   stream: _fileVideoStreamController.stream,
    //   builder: (context, snapshot) {
    //     if (snapshot?.data == true) {
    return FutureBuilder<BetterPlayerController>(
      future: _setupFileVideoData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else {
          return AspectRatio(
            aspectRatio: 16 / 9,
            child: BetterPlayer(
              controller: _betterPlayerController,
            ),
          );
        }
      },
    );
    //       } else {
    //         return const SizedBox();
    //       }
    //     },
    //   );
  }

  @override
  void dispose() {
    _fileVideoStreamController.close();
    super.dispose();
  }
}
