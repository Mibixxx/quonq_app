class Occurrence {
  final DateTime date;
  final int? vasche;
  final int? calorie;

  Occurrence({
    required this.date,
    this.vasche,
    this.calorie,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'vasche': vasche,
        'calorie': calorie,
      };

  factory Occurrence.fromJson(Map<String, dynamic> json) {
    return Occurrence(
      date: DateTime.parse(json['date']),
      vasche: json['vasche'] as int?,
      calorie: json['calorie'] as int?,
    );
  }
}
