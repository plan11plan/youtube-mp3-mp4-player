import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:player/screen/MyApp.dart';
import 'package:player/screen/other/Home_screen.dart';
import 'package:player/screen/other/Music.dart';
import 'package:player/screen/other/Video.dart';
import 'package:player/screen/other/Youtube.dart';
import 'package:player/screen/other/playlist_screen.dart';
import 'package:player/screen/other/song_screen.dart';

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
        GetPage(name: '/song', page: () => const SongScreen()),
        GetPage(name: '/playlist', page: () => const PlaylistScreen()),
      ],
    );
  }
}

//GetMaterialApp의 주요 속성들은 다음과 같습니다:
//
// debugShowCheckedModeBanner: 디버그 모드 배너를 표시할지 여부를 설정합니다. 이 값이 false로 설정되어 있으므로, 디버그 모드 배너는 표시되지 않습니다.
// title: 앱의 제목을 설정합니다. 이 경우, 'Flutter MP3'로 설정되어 있습니다.
// theme: 앱의 전반적인 테마를 설정합니다. 이 경우, 앱의 텍스트 색상이 모두 하얗게 설정되어 있습니다.
// home: 앱이 처음 시작될 때 표시되는 위젯을 설정합니다. 이 경우, HomeScreen 위젯이 표시됩니다.
// getPages: Get 라이브러리의 라우트 관리 기능을 사용하여 페이지를 정의합니다.
// 이 경우, '/', '/song', '/playlist' 라는 세 가지 경로가 각각 HomeScreen, SongScreen, PlaylistScreen 위젯과 연결되어 있습니다.
// 이 코드는 Flutter와 Get 라이브러리를 사용하여 MP3 플레이어 앱을 구현하는 것으로 보입니다.
// 이 앱은 홈 화면, 노래 화면, 재생 목록 화면이 있고, 각 화면은 Get 라이브러리를 사용하여 라우트 관리를 합니다.