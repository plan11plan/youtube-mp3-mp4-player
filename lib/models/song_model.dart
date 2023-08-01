
class Song{
  final String title;
  final String description;
  final String url;
  final String coverUrl;

  Song({
    required this.title,
    required this.description,
    required this.url,
    required this.coverUrl
  });

  static List<Song> songs = [
    Song(
      title: 'Fire',
      description: 'Fire',
      url: 'assets/music/Fire.mp3',
      coverUrl: 'assets/images/Fire.jpeg',
    ),
    Song(
      title: 'Attraction',
      description: 'feat.뚱이',
      url: 'assets/music/attraction.mp3',
      coverUrl: 'assets/images/갖고놀래.jpeg',
    ),
    Song(
      title: 'Tropic Love',
      description: 'Tropic Love',
      url: 'assets/music/Tropic Love.mp3',
      coverUrl: 'assets/images/Tropic Love.jpeg',
    ),
    Song(
      title: 'Wait For You',
      description: 'Wait For You',
      url: 'assets/music/Wait For You.mp3',
      coverUrl: 'assets/images/Wait For You.jpeg',
    ),
    Song(
      title: '고백',
      description: '다이나믹 듀오',
      url: 'assets/music/고백.mp3',
      coverUrl: 'assets/images/고백 2.jpeg',
    ),
    Song(
      title: '아까워',
      description: '재지팩트',
      url: 'assets/music/aka.mp3',
      coverUrl: 'assets/images/아까워어.jpeg',
    ),


  ];

}