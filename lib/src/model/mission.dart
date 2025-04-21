/// Represents a mission from the API
class Mission {
  int id;
  String name;
  String type;
  String description;

  Mission({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      description: json['description'],
    );
  }
}
