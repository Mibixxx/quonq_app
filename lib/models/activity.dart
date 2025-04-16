class Activity {
  String name;
  List<DateTime> occurrences;

  Activity({required this.name, List<DateTime>? occurrences})
      : occurrences = occurrences ?? [];

  int get count => occurrences.length;

  Map<String, dynamic> toJson() => {
        'name': name,
        'occurrences': occurrences.map((e) => e.toIso8601String()).toList(),
      };

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        name: json['name'],
        occurrences: (json['occurrences'] as List)
            .map((e) => DateTime.parse(e))
            .toList(),
      );
}

