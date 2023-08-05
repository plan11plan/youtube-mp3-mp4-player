import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:player/screen/home/GoDownload.dart';
import 'package:player/screen/home/Home_screen.dart';
import 'package:player/screen/home/Music.dart';
import 'package:player/screen/home/Video.dart';
import 'package:player/screen/playlist_screen.dart';
import 'package:player/screen/song_screen.dart';

import 'models/file_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);



  Hive.registerAdapter(MediaFileAdapter());

  await Hive.openBox<int>('skyColorBox');


  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentindex = 0;

  List tabs = [
    Music(),
    Video(),
    GoDownload(),
    // HomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter MP3',
      theme: ThemeData(
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            tabs[currentindex],
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.only(bottom: 0), // adjust this value as needed
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey,
                      width: 0.4,
                    ),
                  ),
                ),
                child: BottomNavigationBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  unselectedItemColor: Colors.white,
                  selectedItemColor: Colors.white,
                  currentIndex: currentindex,
                  type: BottomNavigationBarType.fixed,
                  showUnselectedLabels: false,
                  showSelectedLabels: false,
                  items: const [

                    BottomNavigationBarItem(
                      icon: Icon(Icons.queue_music_sharp),
                      label: 'Music',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.play_circle_outline),
                      label: 'Video',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.youtube_searched_for),
                      label: 'Youtube',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                  ],
                  onTap: (index) {
                    setState(() {
                      currentindex = index;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      getPages: [
        // GetPage(name: '/', page: () => const HomeScreen()),
        // GetPage(name: '/song', page: () => SongScreen()),
        // GetPage(name: '/playlist', page: () => const PlaylistScreen()),
      ],
    );
  }
}
