// 필요한 라이브러리들을 import 합니다.
import 'package:flutter/material.dart';
import 'package:player/models/playlist_model.dart';
import '../../models/song_model.dart';
import '../../widgets/playlist_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/song_card.dart';

// HomeScreen이라는 StatelessWidget을 정의합니다. 이 클래스는 앱의 홈 화면을 나타냅니다.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // build 메소드에서 화면을 그리는 작업을 합니다.
  @override
  Widget build(BuildContext context) {
    List<Song> songs = Song.songs;  // 노래 리스트를 가져옵니다.
    List<Playlist> playlists = Playlist.playlists;  // 플레이리스트를 가져옵니다.

    // 컨테이너 위젯을 사용해 배경의 그라디언트를 설정하고,
    // Scaffold 위젯을 사용해 앱바와 바디를 구성합니다.
    return Container(

        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.deepPurple.shade800.withOpacity(0.99),
                Colors.deepPurple.shade500.withOpacity(0.99),
                Colors.indigo.shade800.withOpacity(0.76),
                Colors.indigo.shade700.withOpacity(0.76),
                Colors.deepPurple.shade300.withOpacity(0.99),
              ],
            )),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          // appBar: _CustomAppBar(),
          body: SingleChildScrollView(
            child: Column(
                children: [
                  _DiscoverMusic(),  // "Discover Music" 부분을 그립니다.
                  _TrendingMusic(songs: songs),  // "Trending Music" 부분을 그립니다.
                  _PlaylistMusic(playlists: playlists)  // "Playlist Music" 부분을 그립니다.
                ]),
          ),
        ));
  }
}

// _PlaylistMusic이라는 StatelessWidget을 정의합니다.
// 이 클래스는 플레이리스트의 음악을 보여주는 부분을 나타냅니다.
class _PlaylistMusic extends StatelessWidget {
  const _PlaylistMusic({
    super.key,
    required this.playlists,
  });

  final List<Playlist> playlists;

  // build 메소드에서 화면을 그리는 작업을 합니다.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(children: [
        SectionHeader(title: 'Playlists', action: 'View More'),  // 섹션 헤더를 그립니다.
        ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.only(top:20),
            physics: const NeverScrollableScrollPhysics(),  // 스크롤을 비활성화합니다.
            itemCount: playlists.length,  // 플레이리스트의 개수만큼 아이템을 만듭니다.
            itemBuilder: ((context,index){  // 각 아이템에 대해 플레이리스트 카드를 생성합니다.
              return PlaylistCard(playlists: playlists[index]);
            }
            ))
      ],),
    );
  }
}

// _TrendingMusic이라는 StatelessWidget을 정의합니다.
// 이 클래스는 트렌딩 음악을 보여주는 부분을 나타냅니다.
class _TrendingMusic extends StatelessWidget {
  const _TrendingMusic({
    super.key,
    required this.songs,
  });

  final List<Song> songs;

  // build 메소드에서 화면을 그리는 작업을 합니다.
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

// _DiscoverMusic이라는 StatelessWidget을 정의합니다.
// 이 클래스는 음악을 검색하는 부분을 나타냅니다.
class _DiscoverMusic extends StatelessWidget {
  const _DiscoverMusic({
    super.key,
  });

  // build 메소드에서 화면을 그리는 작업을 합니다.
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

// _CustomAppBar이라는 StatelessWidget을 정의합니다.
// 이 클래스는 앱바를 나타냅니다.
class _CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _CustomAppBar({super.key});

  // build 메소드에서 화면을 그리는 작업을 합니다.
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
  // 앱바의 높이를 정의합니다.
  Size get preferredSize => const Size.fromHeight(56.0);
}