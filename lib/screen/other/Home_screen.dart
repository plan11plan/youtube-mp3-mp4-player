import 'package:flutter/material.dart';
import 'package:player/models/playlist_model.dart';
import 'package:player/screen/other/Music.dart';

import '../../models/song_model.dart';
import '../../widgets/playlist_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/song_card.dart';
import 'Video.dart';
import 'Youtube.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Song> songs = Song.songs;
    List<Playlist> playlists = Playlist.playlists;

    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.deepPurple.shade800.withOpacity(0.99),
            Colors.deepPurple.shade300.withOpacity(0.99),
          ],
        )),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _CustomAppBar(),
          body: SingleChildScrollView(
            child: Column(
                children: [
              _DiscoverMusic(),
              _TrendingMusic(songs: songs),
              _PlaylistMusic(playlists: playlists)
            ]),
          ),
        ));
  }
}

class _PlaylistMusic extends StatelessWidget {
  const _PlaylistMusic({
    super.key,
    required this.playlists,
  });

  final List<Playlist> playlists;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(children: [
        SectionHeader(title: 'Playlists', action: 'View More'),
        ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.only(top:20),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: playlists.length,
            itemBuilder: ((context,index){
              return PlaylistCard(playlists: playlists[index]);
        }
        ))
      ],),
    );
  }
}

class _TrendingMusic extends StatelessWidget {
  const _TrendingMusic({
    super.key,
    required this.songs,
  });

  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 20.0),
      child: Column(
        children: [
          const Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: SectionHeader(
              title: 'Trending Music',
              action: 'View More',
            ),
          ),
          const SizedBox(height: 20,),
           SizedBox(
            height: MediaQuery.of(context).size.height * 0.27,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: songs.length,
                itemBuilder: (context,index){
                return SongCard(song: songs[index]);
                }

            ),
          )

        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////
class _DiscoverMusic extends StatelessWidget {
  const _DiscoverMusic({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("WELCOME", style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 5),
          Text(
            "Enjoy play music",
            style: Theme.of(context)
                .textTheme
                .headline6!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextFormField(
            decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                hintText: 'Search',
                hintStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                )),
          )
        ],
      ),
    );
  }
}



class _CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: const Icon(Icons.grid_view_rounded),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 20),
          child: const CircleAvatar(
            backgroundImage: AssetImage('asset/image/paka.png'),
          ),
        )
      ],
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(56.0);
}
