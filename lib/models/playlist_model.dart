import 'song_model.dart';
class Playlist {
  final String title;
  final List<Song> songs;
  final String imageUrl;

  Playlist({
    required this.title,
    required this.songs,
    required this.imageUrl
});
  static List<Playlist> playlists = [
      Playlist(title:'락', songs: Song.songs, imageUrl: 'https://i.namu.wiki/i/SG9dcHX0o1cdCcwI6hsggTOCq_pgIXP1ZQpbj5A4Kl3Em3Jj9tFxiiJrapJgF3vTZp7oY6BqTHKa1pael60T4A.webp'),
    Playlist(title: '힙합', songs: Song.songs, imageUrl: 'https://i.namu.wiki/i/MXevKjxv2VKQz3MkTEID26ZyD-0oSN19KC9cCyVRaO_eCsF_C5QGWwuKS00z8dgaHqi7tlliNW0WIM0Lg1KmDACOjsw3xX_PA46e714ECK8sVAgjQ5PsPwaNuaR-kG-wQGF-tW77vnKkT9cQb9eqpw.webp'),
    Playlist(title: '이상', songs: Song.songs, imageUrl: 'https://i.namu.wiki/i/MY_Obocvo_WxLE1pOgve0hbueFuwTJ58tcMBo2pZpsdwkChTDd8TMHnwpkBVwtnQKqJxWoSEAivQgTEKJ2T42ceZpehyCU3B-5-ZtKvFgB4H74_XTjwR9nTrztZPwIQbdQ__e79O2DTbYJo9HvRoVQ.webp')
  ];


}