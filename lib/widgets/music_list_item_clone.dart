// import 'dart:io';
// import 'package:flutter/material.dart';
// import '../../models/file_model.dart';
//
// class MusicListItem extends StatelessWidget {
//   final MediaFile mediaFile;
//
//   MusicListItem({required this.mediaFile});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.all(12.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(5.0),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black54.withOpacity(0.5),
//                       spreadRadius: 3,
//                       blurRadius: 7,
//                       offset: Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(5.0),
//                   child: Image.file(File(mediaFile.thumbnailPath), height: 50, width: 50, fit: BoxFit.cover),
//                 ),
//               ),
//               SizedBox(width: 10),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(height: 10),
//                   Text(mediaFile.title, style: Theme.of(context).textTheme.headline6),
//                   SizedBox(height: 5),
//                   Text(mediaFile.description, style: Theme.of(context).textTheme.subtitle1),
//                 ],
//               ),
//             ],
//           ),
//           IconButton(
//             icon: Icon(Icons.chevron_left, color: Colors.white),
//             onPressed: () {},
//           ),
//         ],
//       ),
//     );
//   }
// }
