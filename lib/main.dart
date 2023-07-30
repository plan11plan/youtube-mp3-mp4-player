import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:player/screen/other/Home_screen.dart';
import 'package:player/screen/other/Music.dart';
import 'package:player/screen/other/Video.dart';
import 'package:player/screen/other/Youtube.dart';
import 'package:player/screen/other/playlist_screen.dart';
import 'package:player/screen/other/song_screen.dart';

import 'models/song_model.dart';

void main() {
  runApp(const MyApp());
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

