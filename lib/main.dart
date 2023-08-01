import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <- Add this line
import 'package:get/get.dart';
import 'package:player/screen/Home_screen.dart';
import 'package:player/screen/Music.dart';
import 'package:player/screen/video/Video.dart';
import 'package:player/screen/playlist_screen.dart';
import 'package:player/screen/song_screen.dart';
import 'package:player/screen/Youtube.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized(); // <- Add this line
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]) // <- Add this line
      .then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentindex =0;

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
          body: tabs[currentindex],
          bottomNavigationBar:  BottomNavigationBar(
            backgroundColor: Colors.deepPurple.shade800,
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
            onTap: (index){
              setState(() {
                currentindex=index;
              });
            },

          )
      ),
      getPages: [
        GetPage(name: '/', page: () => const HomeScreen()),
        GetPage(name: '/song', page: () => SongScreen()),
        GetPage(name: '/playlist', page: () => const PlaylistScreen()),
      ],

    );
  }
}
