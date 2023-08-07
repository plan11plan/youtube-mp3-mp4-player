// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:hive/hive.dart';
// import '../../models/file_model.dart';
// import '../icon/skyColor.dart';
// import '../popup/oneDelete.dart';
// import '../song_screen.dart';
//
// class Liked extends StatefulWidget {
//   const Liked({Key? key}) : super(key: key);
//
//   @override
//   _LikedState createState() => _LikedState();
// }
//
// class _LikedState extends State<Liked> {
//   List<MediaFile> mediaFiles = [];
//   List<MediaFile> filteredMediaFiles = [];
//   TextEditingController _searchController = TextEditingController();
//   bool _isSearching = false;
//
//   @override
//   void initState() {
//     super.initState();
//     openBox();
//     SkyColor.loadColorIndex(); // Video에는 할필요없음 static
//     _searchController.addListener(_onSearchChanged);
//   }
//
//   Future openBox() async {
//     var files = await MediaFile.loadAllLikedAudioFiles();
//     setState(() {
//       mediaFiles = files;
//       filteredMediaFiles = mediaFiles;
//     });
//   }
//
//   void _onSearchChanged() {
//     var search = _searchController.text.toLowerCase();
//     setState(() {
//       filteredMediaFiles = mediaFiles
//           .where((file) => file.title.toLowerCase().contains(search))
//           .toList();
//     });
//   }
//
//   void removeAudioFile(int index) async {
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
//     var updatedAudioFiles = await MediaFile.loadAllLikedAudioFiles();
//     setState(() {
//       mediaFiles = updatedAudioFiles;
//       filteredMediaFiles = updatedAudioFiles;
//     });
//   }
//
//   void _cancelSearch() {
//     _searchController.clear();
//     setState(() {
//       _isSearching = false;
//       filteredMediaFiles = mediaFiles;
//     });
//   }
//
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
//   Future<void> updateLikeStatus(int index) async {
//     var box = Hive.box<MediaFile>('mediaFiles');
//     var fileToUpdate = filteredMediaFiles[index];
//
//     int hiveIndex = box.values.toList().indexOf(fileToUpdate);
//     if (hiveIndex != -1) {
//       if(fileToUpdate.like =='on'){
//         fileToUpdate.like ='off';
//         box.putAt(hiveIndex, fileToUpdate);
//
//       }
//      else{
//         fileToUpdate.like ='on';
//         box.putAt(hiveIndex, fileToUpdate);      }
//     }
//
//     var updatedAudioFiles = await MediaFile.loadAllLikedAudioFiles();
//     setState(() {
//       mediaFiles = updatedAudioFiles;
//       filteredMediaFiles = updatedAudioFiles;
//     });
//   }
//
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
//     var updatedAudioFiles = await MediaFile.loadAllLikedAudioFiles();
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
//
//                       endActionPane: ActionPane(
//                         motion: const ScrollMotion(),
//                         children: [
//                           SlidableAction(
//                             onPressed: (context) async {
//                               await updateLikeStatus(index);
//                               setState(() {}); // UI를 갱신합니다.
//                             },
//                             backgroundColor: filteredMediaFiles[index].like == "on"
//                                 ? Colors.red.shade300
//                                 : Colors.transparent, // 좋아요 상태에 따라 배경색을 변경
//                             foregroundColor: filteredMediaFiles[index].like == "on"
//                                 ? Colors.white
//                                 : Colors.grey, // 좋아요 상태에 따라 아이콘 색을 변경
//                             icon: Icons.favorite,
//                             label: 'like',
//                           ),
//
//
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
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }