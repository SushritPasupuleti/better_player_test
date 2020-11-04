import 'dart:async';
import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:better_player_test/playlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
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
      home: MyHomePage(title: "Some Title"),
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
  int _counter = 3;
  BetterPlayerController _betterPlayerController;
  StreamController<bool> _fileVideoStreamController =
      StreamController.broadcast();
  bool _fileVideoShown = true;

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
        ),
        looping: true,
      ),
      betterPlayerDataSource: dataSource,
    );

    _betterPlayerController.addEventsListener((event) {
      if (_counter > 0) {
        if (event.betterPlayerEventType == BetterPlayerEventType.FINISHED) {
          print(
              "Better player event: ${event.betterPlayerEventType}, $_counter remaining");
          // _betterPlayerController.setLooping(true);
          //_decrementCounter();
          // setState(() {
          //   _counter -= 1;
          // });
          // if (_counter == 0) {
          //   _betterPlayerController.pause();
          //   // _betterPlayerController.setLooping(false);
          // }
        }
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
      _buildFileVideo(),
      //RaisedButton(child: Text("Playlist"), onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => PlaylistPage()));}),
      FloatingActionButton(
        onPressed: null,
        child: Text("$_counter"),
      )
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
            child: 
            BetterPlayer(
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

// class HomeSwiper extends StatefulWidget {
//   HomeSwiper({Key key}) : super(key: key);

//   @override
//   _HomeSwiperState createState() => _HomeSwiperState();
// }

// class _HomeSwiperState extends State<HomeSwiper> {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "Video Title",
//       home: Scaffold(
//           backgroundColor: Colors.black,
//           body: new Padding(
//               padding: EdgeInsets.fromLTRB(0, 25, 0, 25),
//               child: Swiper(
//                 itemBuilder: (BuildContext context, int index) {
//                   return new MyHomePage(title: "Some Title");
//                 },
//                 itemCount: 10,
//                 viewportFraction: 0.8,
//                 scale: 0.9,
//                 pagination: new SwiperPagination(
//                     builder: SwiperPagination.fraction,
//                     margin: EdgeInsets.fromLTRB(0, 10, 0, 0)),
//                 control: new SwiperControl(
//                     iconNext: Icons.navigate_next_rounded,
//                     iconPrevious: Icons.navigate_before_rounded,
//                     size: 125),
//                 loop: false,
//               ))),
//     );
//   }
// }