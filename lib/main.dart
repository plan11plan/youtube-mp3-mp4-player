import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:player/screen/home/GoDownload.dart';
import 'package:player/screen/home/Home_screen.dart';
import 'package:player/screen/home/Liked.dart';
import 'package:player/screen/home/Music.dart';
import 'package:player/screen/home/Video.dart';
import 'package:player/screen/playlist_screen.dart';
import 'package:player/screen/song_screen.dart';

import 'models/file_model.dart';

Future<void> main() async {
  await Hive.initFlutter();
  WidgetsFlutterBinding.ensureInitialized();


  //어답터 등록하기
  Hive.registerAdapter<MediaFile>(MediaFileAdapter());

  //박스 열기
  await Hive.openBox<MediaFile>('mediaFiles');
  await Hive.openBox<int>('skyColorBox');
  await Hive.openBox('settings');  // 여기서 settings box를 열어줍니다.

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

  int currentindex = 0;

  List tabs = [
    Music(),
    // Video(),
    GoDownload(),
    // Liked()
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
                child: CurvedNavigationBar(
                  key: _bottomNavigationKey,
                  items: const [
                    Icon(Icons.queue_music_sharp, size: 25,color: Colors.grey,),
                    Icon(Icons.play_circle_outline, size: 25,color: Colors.grey),
                    Icon(Icons.youtube_searched_for, size: 25,color: Colors.grey),
                    Icon(Icons.home, size: 25,color: Colors.grey),
                  ],
                  color: Colors.grey.withOpacity(0.4),
                  // color: Colors.black.withOpacity(0.3),
                  // buttonBackgroundColor: Colors.blueAccent.withOpacity(0.1),
                  // buttonBackgroundColor: Colors.black.withOpacity(0.3),
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
      getPages: [
        // GetPage(name: '/', page: () => const HomeScreen()),
        GetPage(name: '/song', page: () => SongScreen()),
        // GetPage(name: '/playlist', page: () => const PlaylistScreen()),
      ],
    );
  }
}