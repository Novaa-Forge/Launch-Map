/// Class represents a launch service provider from the API.
class LaunchServiceProvider {
  int id;
  String url;
  String name;
  String abbrev;

  LaunchServiceProvider({
    required this.id,
    required this.url,
    required this.name,
    required this.abbrev,
  });

  factory LaunchServiceProvider.fromJson(Map<String, dynamic> json) {
    return LaunchServiceProvider(
      id: json['id'],
      url: json['url'],
      name: json['name'],
      abbrev: json['abbrev'],
    );
  }
}
