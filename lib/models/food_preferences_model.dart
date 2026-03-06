class FoodPreferences {
  final String? dietType;
  final List<String> allergies;
  final List<String> dislikes;

  const FoodPreferences({
    this.dietType,
    this.allergies = const [],
    this.dislikes = const [],
  });

  factory FoodPreferences.fromJson(Map<String, dynamic> json) {
    return FoodPreferences(
      dietType: json['dietType'] as String?,
      allergies: _stringListFromJson(json['allergies']),
      dislikes: _stringListFromJson(json['dislikes']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'dietType': dietType, 'allergies': allergies, 'dislikes': dislikes};
  }

  static List<String> _stringListFromJson(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList(growable: false);
    }
    return const [];
  }
}
