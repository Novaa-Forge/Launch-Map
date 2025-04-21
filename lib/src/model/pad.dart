/// Represents a pad from the API.
/// [lat] and [long] are used to locate the icons on the map
class Pad {
  int id;
  String url;
  String name;
  String? imageUrl;
  double lat;
  double long;
  String country;

  Pad({
    required this.id,
    required this.url,
    required this.name,
    required this.imageUrl,
    required this.lat,
    required this.long,
    required this.country,
  });

  factory Pad.fromJson(Map<String, dynamic> json) {
    return Pad(
      id: json['id'],
      url: json['url'],
      name: json['name'],
      imageUrl: json['image'] != null ? json['image']['image_url'] : null,
      lat: json['latitude'],
      long: json['longitude'],
      country: json['country']['name'],
    );
  }
}
