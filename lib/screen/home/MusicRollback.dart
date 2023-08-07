// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import '../../models/file_model.dart';
// import '../icon/skyColor.dart';
// import '../popup/oneDelete.dart';
// import '../song_screen.dart';
//
// class Music extends StatefulWidget {
//   const Music({Key? key}) : super(key: key);
//
//   @override
//   _MusicState createState() => _MusicState();
// }
//
// class _MusicState extends State<Music> {
//   List<MediaFile> mediaFiles = []; //모든 미디어 파일을 저장하는 리스트입니다.
//   List<MediaFile> filteredMediaFiles = []; //검색 쿼리와 일치하는 미디어 파일을 저장하는 리스트입니다.
//   TextEditingController _searchController = TextEditingController(); //: 검색 입력을 처리하는 컨트롤러입니다.
//   bool _isSearching = false; //현재 검색이 활성화되어 있는지를 나타내는 부울 플래그입니다.
//
//   @override
//   void initState() {
//     super.initState();
//     openBox(); //openBox(): 미디어 파일을 로드하는 메서드입니다.
//     SkyColor.loadColorIndex(); // 색상 관련 데이터를 로드
//     _searchController.addListener(_onSearchChanged);//검색 컨트롤러에 리스너를 추가
//   }
//
//   //openBox(): 모든 오디오 파일을 비동기적으로 로드하고 새로운 파일 리스트로 상태를 업데이트합니다.
//   Future openBox() async {
//     var files = await MediaFile.loadAllAudioFiles();
//     setState(() {
//       mediaFiles = files;
//       filteredMediaFiles = mediaFiles;
//     });
//   }
//
//   //_onSearchChanged(): 검색 쿼리에 따라 미디어 파일의 리스트를 필터링하는 메서드입니다.
//   void _onSearchChanged() {
//     var search = _searchController.text.toLowerCase();
//     setState(() {
//       filteredMediaFiles = mediaFiles
//           .where((file) => file.title.toLowerCase().contains(search))
//           .toList();
//     });
//   }
//   //removeAudioFile(int index): 미디어 파일을 삭제하는 메서드입니다.
//   void removeAudioFile(int index) async {
//     //박스 열기.
//     var box = Hive.box<MediaFile>('mediaFiles');
//     var fileToDelete = filteredMediaFiles[index];
//     var file = File(fileToDelete.filePath);
//
//     if (file.existsSync()) {
//       file.deleteSync();
//     }
//
//     int hiveIndex = box.values.toList().indexOf(fileToDelete);
//     if (hiveIndex != -1) {
//       box.deleteAt(hiveIndex);
//     }
//
//     var updatedAudioFiles = await MediaFile.loadAllAudioFiles();
//     setState(() {
//       mediaFiles = updatedAudioFiles;
//       filteredMediaFiles = updatedAudioFiles;
//     });
//   }
//   //_cancelSearch(): 검색 입력을 초기화하고 모든 파일을 표시하도록 필터링된 미디어 파일을 재설정합니다.
//   void _cancelSearch() {
//     _searchController.clear();
//     setState(() {
//       _isSearching = false;
//       filteredMediaFiles = mediaFiles;
//     });
//   }
//
//   //showDeleteConfirmationDialog(): 사용자가 미디어 파일을 삭제하려고 할 때 확인 대화 상자를 표시합니다.
//   Future<void> showDeleteConfirmationDialog(BuildContext context, int index) async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return OneDeleteDialog(
//           onDelete: removeAudioFile,
//           index: index,
//         );
//       },
//     );
//   }
//   Future<void> showEditDialog(BuildContext context, int index) async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         var titleController = TextEditingController(text: filteredMediaFiles[index].title);
//         var descriptionController = TextEditingController(text: filteredMediaFiles[index].description);
//
//         return AlertDialog(
//           title: Text('Edit File',style: TextStyle(color: Colors.black, fontSize: 45,fontFamily:'font1'),),
//           contentPadding: EdgeInsets.all(15.0),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
//           backgroundColor: Colors.grey[800],
//           content: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 SizedBox(height: 20), // 여기서 공간을 추가합니다.
//                 Text("Title : ", style: TextStyle(color: Colors.white, fontSize: 20)),
//                 SizedBox(height: 10),
//                 TextField(
//                   controller: titleController,
//                   decoration: InputDecoration(
//                     hintText: 'Title',
//                     hintStyle: TextStyle(color: Colors.grey),
//                     enabledBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: Colors.white),
//                     ),
//                   ),
//                   style: TextStyle(color: Colors.white),
//                 ),
//                 SizedBox(height: 20), // 여기서 공간을 추가합니다.
//                 Text("Artist : ", style: TextStyle(color: Colors.white, fontSize: 20)),
//                 SizedBox(height: 10),
//                 TextField(
//                   controller: descriptionController,
//                   decoration: InputDecoration(
//                     hintText: 'Artist',
//                     hintStyle: TextStyle(color: Colors.grey),
//                     enabledBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: Colors.white),
//                     ),
//                   ),
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Save', style: TextStyle(color: Colors.green)),
//               onPressed: () {
//                 updateFileDetails(index, titleController.text, descriptionController.text);
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text('Cancel', style: TextStyle(color: Colors.white)),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//
//
//
//       },
//     );
//   }
//   void updateLikeStatus(int index) async {
//     var box = Hive.box<MediaFile>('mediaFiles');
//     var fileToUpdate = filteredMediaFiles[index];
//
//     int hiveIndex = box.values.toList().indexOf(fileToUpdate);
//     if (hiveIndex != -1) {
//       fileToUpdate.like = !fileToUpdate.like;
//       box.putAt(hiveIndex, fileToUpdate);
//     }
//
//     var updatedAudioFiles = await MediaFile.loadAllAudioFiles();
//     setState(() {
//       mediaFiles = updatedAudioFiles;
//       filteredMediaFiles = updatedAudioFiles;
//     });
//   }
//   void updateFileDetails(int index, String newTitle, String newDescription) async {
//     var box = Hive.box<MediaFile>('mediaFiles');
//     var fileToUpdate = filteredMediaFiles[index];
//
//     int hiveIndex = box.values.toList().indexOf(fileToUpdate);
//     if (hiveIndex != -1) {
//       fileToUpdate.title = newTitle;
//       fileToUpdate.description = newDescription;
//       box.putAt(hiveIndex, fileToUpdate);
//     }
//
//     var updatedAudioFiles = await MediaFile.loadAllAudioFiles();
//     setState(() {
//       mediaFiles = updatedAudioFiles;
//       filteredMediaFiles = updatedAudioFiles;
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         FocusScope.of(context).unfocus();
//       },
//       child: Container(
//         decoration: SkyColor.skyDecoration,
//         child: Scaffold(
//           backgroundColor: Colors.transparent,
//           body: Column(
//             children: [
//               SafeArea(
//                 child: Row(
//                   children: [
//                     Expanded(
//                       flex: 2,
//                       child: Container(
//                         margin: EdgeInsets.symmetric(horizontal: 19),
//                         height: 45,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(15),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.blueGrey.withOpacity(0.2),
//                               spreadRadius: 4,
//                               blurRadius: 14,
//                               offset: Offset(0, 1),
//                             ),
//                           ],
//                         ),
//                         child: TextFormField(
//                           controller: _searchController,
//                           decoration: InputDecoration(
//                             hintText: "Search the music",
//                             hintStyle: TextStyle(
//                                 color: Colors.white.withOpacity(0.5),
//                                 fontFamily: 'font1',fontWeight: FontWeight.w800,fontSize: 17
//                             ),
//                             border: InputBorder.none,
//                             prefixIcon: IconButton(
//                               icon: Icon(Icons.search, size: 23,
//                                   color: Colors.white.withOpacity(0.5)),
//                               onPressed: () {},
//                             ),
//                             suffixIcon: _isSearching
//                                 ? IconButton(
//                               icon: Icon(Icons.close, size: 23,
//                                   color: Colors.white.withOpacity(0.5)),
//                               onPressed: _cancelSearch,
//                             )
//                                 : null,
//                           ),
//                           onChanged: (value) {
//                             setState(() {
//                               _isSearching = value.isNotEmpty;
//                             });
//                           },
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       flex: 1,
//                       child: Padding(
//                         padding: EdgeInsets.only(right: 10),
//                         child: MoonIconButton(
//                           callback: () {
//                             setState(() {});
//                           },
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: ListView.separated(
//                   itemCount: filteredMediaFiles.length,
//                   separatorBuilder: (context, index) =>
//                       Divider(color: Colors.white54),
//                   itemBuilder: (context, index) {
//                     return Slidable(
//                       key: Key(filteredMediaFiles[index].title),
//                       startActionPane: ActionPane(
//                         motion: const ScrollMotion(),
//                         children: const [
//                           // 왼쪽(또는 위쪽)에 표시할 액션을 여기에 추가합니다.
//                         ],
//                       ),
//                       endActionPane: ActionPane(
//                         motion: const ScrollMotion(),
//                         children: [
//                           SlidableAction(
//                             onPressed: (context) {
//                               updateLikeStatus(index);
//                             },
//                             backgroundColor: filteredMediaFiles[index].like
//                                 ? Colors.red.shade300
//                                 : Colors.transparent,  // 색상은 좋아요 여부에 따라 변경
//                             foregroundColor: filteredMediaFiles[index].like
//                                 ? Colors.white
//                                 : Colors.grey,  // 색상은 좋아요 여부에 따라 변경
//                             icon: Icons.favorite,
//                             label: 'like',
//
//                           ),
//
//                           SlidableAction(
//                             onPressed: (context) => showEditDialog(context, index),
//                             backgroundColor: Colors.transparent,
//                             foregroundColor: Colors.grey,
//                             icon: Icons.settings,
//                             label: 'set',
//                           ),
//                           SlidableAction(
//                             onPressed: (context) => showDeleteConfirmationDialog(context, index),
//                             backgroundColor: Colors.transparent,
//                             foregroundColor: Colors.grey,
//                             icon: Icons.delete,
//                             label: 'delete',
//                           ),
//                         ],
//                       ),
//                       child: InkWell(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => SongScreen(mediaFile: filteredMediaFiles[index], index: index),
//                             ),
//                           );
//                         },
//                         child: Padding(
//                           padding: EdgeInsets.all(12.0),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Row(
//                                 children: [
//                                   Container(
//                                     decoration: BoxDecoration(
//                                       color: Colors.grey[300],
//                                       borderRadius: BorderRadius.circular(5.0),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.black54.withOpacity(0.5),
//                                           spreadRadius: 3,
//                                           blurRadius: 7,
//                                           offset: Offset(0, 3),
//                                         ),
//                                       ],
//                                     ),
//                                     child: ClipRRect(
//                                       borderRadius: BorderRadius.circular(5.0),
//                                       child: Image.file(File(filteredMediaFiles[index].thumbnailPath), height: 50, width: 50, fit: BoxFit.cover),
//                                     ),
//                                   ),
//                                   SizedBox(width: 10),
//                                   Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       SizedBox(height: 10),
//                                       Text(filteredMediaFiles[index].title, style: Theme.of(context).textTheme.headline6),
//                                       SizedBox(height: 5),
//                                       Text(filteredMediaFiles[index].description, style: Theme.of(context).textTheme.subtitle1),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                               IconButton(
//                                 icon: Icon(Icons.chevron_left, color: Colors.white),
//                                 onPressed: () {},
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//
//
//
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }