/// Represents a rocket from the API
class Rocket {
  int id;
  String name;
  String fullName;
  String url;

  Rocket({
    required this.id,
    required this.name,
    required this.fullName,
    required this.url,
  });

  factory Rocket.fromJson(Map<String, dynamic> json) {
    return Rocket(
      id: json['id'],
      name: json['configuration']['name'],
      fullName: json['configuration']['full_name'],
      url: json['configuration']['url'],
    );
  }
}
