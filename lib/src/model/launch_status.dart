/// Represents a launch status from the API
class LaunchStatus {
  int id;
  String name;
  String abbrev;
  String description;

  LaunchStatus({
    required this.id,
    required this.name,
    required this.abbrev,
    required this.description,
  });

  factory LaunchStatus.fromJson(Map<String, dynamic> json) {
    return LaunchStatus(
      id: json['id'],
      name: json['name'],
      abbrev: json['abbrev'],
      description: json['description'],
    );
  }
}
