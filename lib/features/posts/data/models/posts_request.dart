

class PostRequest {
  final int userId;
  final double latitude;
  final double longitude;

  PostRequest({
    required this.userId,
    required this.latitude,
    required this.longitude
  });

  Map<String, dynamic> toJson(){
    return {
      'userId' : userId,
      'latitude' : latitude,
      'longitude' : longitude
    };
  }
}