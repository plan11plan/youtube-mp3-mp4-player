import 'package:audio_service/audio_service.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:player/screen/home/GoDownload.dart';
import 'package:player/screen/home/Home_screen.dart';
import 'package:player/screen/home/Music.dart';
import 'package:player/screen/home/Playlist.dart';
import 'package:player/screen/home/Video.dart';

import 'models/file_model.dart';




Future<void> main() async {
  await Hive.initFlutter();
  WidgetsFlutterBinding.ensureInitialized();


  //어답터 등록하기
  Hive.registerAdapter<MediaFile>(MediaFileAdapter());
  Hive.registerAdapter<Playlist>(PlaylistAdapter());


  //박스 열기
  await Hive.openBox<MediaFile>('mediaFiles');
  await Hive.openBox<int>('skyColorBox');
  await Hive.openBox('settings');  // 여기서 settings box를 열어줍니다.
  await Hive.openBox<Playlist>('playlists');


  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.myAudioPlayer',
    androidNotificationChannelName: 'myAudioPlayer',
    androidNotificationOngoing: true,
  );

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
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  int currentindex = 0;

  List tabs = [
    Music(),
    PlaylistCreationScreen(),
    Video(),
    GoDownload(),
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
                child: CurvedNavigationBar(
                  key: _bottomNavigationKey,
                  items: const [
                    Icon(Icons.music_note, size: 25, color: Colors.white),
                    Icon(Icons.queue_music_sharp, size: 25, color: Colors.white),
                    Icon(Icons.play_circle_outline, size: 25, color: Colors.white),
                    Icon(Icons.youtube_searched_for, size: 25, color: Colors.white),

                  ],
                  color:Colors.black ,  // 바텀 네비게이션의 배경색을 조절합니다.
                  buttonBackgroundColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  animationCurve: Curves.easeInOut,
                  animationDuration: Duration(milliseconds: 500),
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
    );
  }





}