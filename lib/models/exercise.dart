class Exercise {
  final String id;
  final String name;
  final String force;
  final String level;
  final String mechanic;
  final String equipment;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final String gifUrl;
  final List<String> images;

  Exercise({
    required this.id,
    required this.name,
    required this.force,
    required this.level,
    required this.mechanic,
    required this.equipment,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.gifUrl,
    required this.images,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      force: json['force'] ?? '',
      level: json['level'] ?? '',
      mechanic: json['mechanic'] ?? '',
      equipment: json['equipment'] ?? '',
      primaryMuscles: List<String>.from(json['primaryMuscles'] ?? []),
      secondaryMuscles: List<String>.from(json['secondaryMuscles'] ?? []),
      gifUrl: json['gifUrl'] ?? '',
      images: List<String>.from(json['images'] ?? []),
    );
  }
}
