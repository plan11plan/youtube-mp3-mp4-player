// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:hive/hive.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import '../../models/file_model.dart';
// import '../icon/skyColor.dart';
// import '../popup/oneDelete.dart';
//
// class Music extends StatefulWidget {
//   const Music({Key? key}) : super(key: key);
//
//   @override
//   _MusicState createState() => _MusicState();
// }
//
// class _MusicState extends State<Music> {
//   TextEditingController _searchController = TextEditingController();
//   bool _isSearching = false;
//   List<MediaFile> _filteredMediaFiles = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _openHiveBox();
//     SkyColor.loadColorIndex();
//     _searchController.addListener(_onSearchChanged);
//   }
//
//   Future<void> _openHiveBox() async {
//     if (!Hive.isBoxOpen('mediaFiles')) {
//       await Hive.openBox<MediaFile>('mediaFiles');
//     }
//   }
//
//   void _onSearchChanged() {
//     setState(() {
//       _isSearching = _searchController.text.isNotEmpty;
//       _filterMediaFiles(_searchController.text);
//     });
//   }
//
//   void removeAudioFile(int index) {
//     var box = Hive.box<MediaFile>('mediaFiles');
//     var fileToDelete = box.getAt(index);
//     if (fileToDelete != null) {
//       var file = File(fileToDelete.filePath);
//       if (file.existsSync()) {
//         file.deleteSync();
//       }
//       box.deleteAt(index);
//     }
//   }
//
//   void _filterMediaFiles(String searchText) {
//     var box = Hive.box<MediaFile>('mediaFiles');
//     _filteredMediaFiles = box.values
//         .where((file) =>
//         file.title.toLowerCase().contains(searchText.toLowerCase()))
//         .toList();
//   }
//
//   void _cancelSearch() {
//     _searchController.clear();
//   }
//
//   Future<void> showDeleteConfirmationDialog(
//       BuildContext context, int index) async {
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
//
//   Future<void> showEditDialog(BuildContext context, int index) async {
//     final int maxTextLength = 12;
//     var box = Hive.box<MediaFile>('mediaFiles');
//     var currentFile = box.getAt(index);
//     var titleController = TextEditingController(text: currentFile?.title ?? "");
//     var descriptionController =
//     TextEditingController(text: currentFile?.description ?? "");
//
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(
//             'Edit File',
//             style: TextStyle(
//                 color: Colors.black, fontSize: 45, fontFamily: 'font1'),
//           ),
//           contentPadding: EdgeInsets.all(15.0),
//           shape:
//           RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
//           backgroundColor: Colors.grey[800],
//           content: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 SizedBox(height: 20), // 여기서 공간을 추가합니다.
//                 Text("Title : ",
//                     style: TextStyle(color: Colors.white, fontSize: 20)),
//                 SizedBox(height: 10),
//                 TextField(
//                   controller: titleController,
//                   maxLength: maxTextLength,
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
//                 Text("Artist : ",
//                     style: TextStyle(color: Colors.white, fontSize: 20)),
//                 SizedBox(height: 10),
//                 TextField(
//                   controller: descriptionController,
//                   maxLength: maxTextLength,
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
//                 updateFileDetails(
//                     index, titleController.text, descriptionController.text);
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
//       },
//     );
//   }
//
//   //updateLikeStatus() 메서드 변경: ValueListenableBuilder를 사용하여
//   // Hive.box가 업데이트될 때마다 위젯이 다시 빌드되므로, 상태 업데이트가 필요 없어졌습니다.
//   void updateLikeStatus(int index) {
//     var box = Hive.box<MediaFile>('mediaFiles');
//     var fileToUpdate = box.getAt(index);
//     if (fileToUpdate != null) {
//       // Toggle the like value
//       fileToUpdate.like = fileToUpdate.like == 'off' ? 'on' : 'off';
//       box.putAt(index, fileToUpdate);
//     }
//   }
//
//   void updateFileDetails(int index, String newTitle, String newDescription) {
//     var box = Hive.box<MediaFile>('mediaFiles');
//     var fileToUpdate = box.getAt(index);
//     if (fileToUpdate != null) {
//       fileToUpdate.title = newTitle;
//       fileToUpdate.description = newDescription;
//       box.putAt(index, fileToUpdate);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder(
//         valueListenable: Hive.box<MediaFile>('mediaFiles').listenable(),
//         builder: (context, Box<MediaFile> box, _) {
//           var mediaFiles =
//           _isSearching ? _filteredMediaFiles : box.values.toList();
//           return GestureDetector(
//               onTap: () {
//                 FocusScope.of(context).unfocus();
//               },
//               child: Container(
//                 decoration: SkyColor.skyDecoration,
//                 child: Scaffold(
//                   backgroundColor: Colors.transparent,
//                   body: Column(
//                     children: [
//                       SafeArea(
//                         child: Row(
//                           children: [
//                             Expanded(
//                               flex: 2,
//                               child: Container(
//                                 margin: EdgeInsets.symmetric(horizontal: 19),
//                                 height: 45,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(15),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.blueGrey.withOpacity(0.2),
//                                       spreadRadius: 5,
//                                       blurRadius: 14,
//                                       offset: Offset(0, 1),
//                                     ),
//                                   ],
//                                 ),
//                                 child: TextFormField(
//                                   controller: _searchController,
//                                   decoration: InputDecoration(
//                                     hintText: "Search the music",
//                                     hintStyle: TextStyle(
//                                         color: Colors.white.withOpacity(0.5),
//                                         fontFamily: 'font1',
//                                         fontWeight: FontWeight.w800,
//                                         fontSize: 17),
//                                     border: InputBorder.none,
//                                     prefixIcon: IconButton(
//                                       icon: Icon(Icons.search,
//                                           size: 23,
//                                           color: Colors.white.withOpacity(0.5)),
//                                       onPressed: () {},
//                                     ),
//                                     suffixIcon: _isSearching
//                                         ? IconButton(
//                                       icon: Icon(Icons.close,
//                                           size: 23,
//                                           color: Colors.white
//                                               .withOpacity(0.5)),
//                                       onPressed: _cancelSearch,
//                                     )
//                                         : null,
//                                   ),
//                                   onChanged: (value) {
//                                     setState(() {
//                                       _isSearching = value.isNotEmpty;
//                                     });
//                                   },
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               flex: 1,
//                               child: Padding(
//                                 padding: EdgeInsets.only(right: 20),
//                                 child: MoonIconButton(
//                                   callback: () {
//                                     setState(() {});
//                                   },
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         child: ListView.builder(
//                           itemCount: mediaFiles.length,
//                           itemBuilder: (context, index) {
//                             ////////////////////////////////////////
//                             return Container(
//                               width: MediaQuery.of(context).size.width * 1.0,  // Adjust this value to control the width
//                               // Adjust this value to control the width
//                               margin: EdgeInsets.symmetric(
//                                   vertical: 9.0, horizontal:35.0),
//                               decoration: BoxDecoration(
//                                 color: Colors.transparent,
//                                 borderRadius: BorderRadius.circular(15.0),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.grey.withOpacity(0.4),
//                                     spreadRadius: 0.2,
//                                     blurRadius: 3,
//                                     offset: Offset(5, 3),
//                                   ),
//                                 ],
//                               ),
//                               ///////////////////////////////////////////////////         /////////////////
//                               child: Slidable(
//                                 key: Key(mediaFiles[index].title),
//                                 endActionPane: ActionPane(
//                                   motion: const ScrollMotion(),
//                                   children: [
//                                     SlidableAction(
//                                       onPressed: (context) {
//                                         updateLikeStatus(index);
//                                       },
//                                       backgroundColor: mediaFiles[index].like ==
//                                           'on'
//                                           ? Colors.red.shade300
//                                           : Colors
//                                           .transparent, // 색상은 좋아요 여부에 따라 변경
//                                       foregroundColor: mediaFiles[index].like ==
//                                           'on'
//                                           ? Colors.white
//                                           : Colors.grey, // 색상은 좋아요 여부에 따라 변경
//                                       icon: Icons.favorite,
//                                     ),
//                                     SlidableAction(
//                                       onPressed: (context) =>
//                                           showEditDialog(context, index),
//                                       backgroundColor: Colors.transparent,
//                                       foregroundColor: Colors.white,
//                                       icon: Icons.settings,
//                                     ),
//                                     SlidableAction(
//                                       onPressed: (context) =>
//                                           showDeleteConfirmationDialog(
//                                               context, index),
//                                       backgroundColor: Colors.transparent,
//                                       foregroundColor: Colors.white,
//                                       icon: Icons.delete,
//                                     ),
//                                   ],
//                                 ),
//                                 /////
//                                 child: InkWell(
//                                   onTap: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => SongScreen(
//                                             mediaFile: mediaFiles[index],
//                                             index: index),
//                                       ),
//                                     );
//                                   },
//                                   child: Padding(
//                                     padding: EdgeInsets.all(5.0),
//                                     child: Row(
//                                       crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                       children: [
//                                         Row(
//                                           children: [
//                                             // SizedBox(width: 35),
//                                             Container(
//                                               decoration: BoxDecoration(
//                                                 color: Colors.grey[300],
//                                                 borderRadius:
//                                                 BorderRadius.circular(5.0),
//                                                 boxShadow: [
//                                                   BoxShadow(
//                                                     color: Colors.black54
//                                                         .withOpacity(0.4),
//                                                     spreadRadius: 4,
//                                                     blurRadius: 8,
//                                                     offset: Offset(0, 5),
//                                                   ),
//                                                 ],
//                                               ),
//                                               child: ClipRRect(
//                                                 borderRadius:
//                                                 BorderRadius.circular(5.0),
//                                                 child: Image.file(
//                                                     File(mediaFiles[index]
//                                                         .thumbnailPath),
//                                                     height: 60,
//                                                     width: 60,
//                                                     fit: BoxFit.cover),
//                                               ),
//                                             ),
//                                             SizedBox(width: 13),
//                                             Column(
//                                               crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                               children: [
//                                                 SizedBox(height: 2),
//                                                 Text(mediaFiles[index].title,
//                                                     style: Theme.of(context)
//                                                         .textTheme
//                                                         .headline6
//                                                         ?.copyWith(
//                                                         fontSize: 15.0)),
//                                                 SizedBox(height: 10),
//                                                 Text(
//                                                     mediaFiles[index]
//                                                         .description,
//                                                     style: Theme.of(context)
//                                                         .textTheme
//                                                         .subtitle1
//                                                         ?.copyWith(
//                                                         fontSize: 10.0)),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                         Spacer(),
//                                         Padding(
//                                           padding: EdgeInsets.only(
//                                               top: 12.0, right: 0),
//                                           child: Text(
//                                             mediaFiles[index].duration,
//                                             style: TextStyle(
//                                                 fontSize: 14.0,
//                                                 color: Colors.white),
//                                           ),
//                                         ),
//                                         Padding(
//                                           padding: EdgeInsets.only(
//                                               top: 5.0, right: 0),
//                                           child: IconButton(
//                                             icon: Icon(Icons.chevron_left,
//                                                 color: Colors.white),
//                                             onPressed: null,
//                                           ),
//                                         ),
//                                         // SizedBox(width: 20),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//
//                       SizedBox(height: 180,)
//                     ],
//                   ),
//                 ),
//               ));
//         });
//   }
// }