
class downVideo{
  final String title;
  final String description;
  final String url;
  final String coverUrl;

  downVideo({
    required this.title,
    required this.description,
    required this.url,
    required this.coverUrl
  });

  static List<downVideo> videos = [
    downVideo(
      title: 'ride',
      description: 'ride',
      url: 'assets/video/ride.mp4',
      coverUrl: 'assets/images/Fire.jpeg',
    ),
    downVideo(
      title: 'ride2',
      description: 'ride2',
      url: 'assets/video/ride2.mp4',
      coverUrl: 'assets/images/갖고놀래.jpeg',
    ),
    downVideo(
      title: 'ride3',
      description: 'ride3',
      url: 'assets/video/ride3.mp4',
      coverUrl: 'assets/images/Tropic Love.jpeg',
    ),
    downVideo(
      title: 'ride4',
      description: 'ride4',
      url: 'assets/video/금요일 밤.mp4',
      coverUrl: 'assets/images/금요일 밤.jpeg',
    ),
    // downVideo(
    //   title: 'ride5',
    //   description: 'ride5',
    //   url: 'assets/video/시차.mp4',
    //   coverUrl: 'assets/images/시차.jpeg',
    // ),


  ];

}