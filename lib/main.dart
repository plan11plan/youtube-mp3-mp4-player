import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:player/screen/home/Home_screen.dart';
import 'package:player/screen/home/Music.dart';
import 'package:player/screen/home/Video.dart';
import 'package:player/screen/playlist_screen.dart';
import 'package:player/screen/song_screen.dart';
import 'package:player/screen/home/Youtube.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
    HomeScreen(),
    Music(),
    Video(),
    Youtube(),
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
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
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
                    )
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
        GetPage(name: '/', page: () => const HomeScreen()),
        GetPage(name: '/song', page: () => SongScreen()),
        GetPage(name: '/playlist', page: () => const PlaylistScreen()),
      ],
    );
  }
}
