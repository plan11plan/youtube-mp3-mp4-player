import 'package:flutter/material.dart';
import 'package:player/screen/Music.dart';
import 'package:player/screen/Setting.dart';
import 'package:player/screen/Video.dart';
import 'Youtube.dart';
import 'home_screen.dart';

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentindex =0;

  List tabs = [
    Music(),
    Video(),
    Youtube(),
    HomeScreen(),

  ];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Music Player App",
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          brightness: Brightness.dark
        ),
        home: Scaffold(
            backgroundColor: Colors.grey,
            appBar: AppBar(
            title: Text("Music Player App~~main.dart"),
          ),
          body: tabs[currentindex],
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            currentIndex: currentindex,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.music_note,),
                label: 'Music',
              ),
        BottomNavigationBarItem(
          icon: Icon(Icons.cloud_upload,),
          label: 'Video',
        ),
              BottomNavigationBarItem(
                icon: Icon(Icons.youtube_searched_for),
                label: 'Youtube',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings,),
                label: 'Setting',
              ),
            ],
            onTap: (index){
              setState(() {
                currentindex=index;
              });
            },
          ),
        )
    );
  }
}