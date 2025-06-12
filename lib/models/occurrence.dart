class Occurrence {
  final DateTime date;
  final int? vasche;

  Occurrence({required this.date, this.vasche});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'vasche': vasche,
      };

  factory Occurrence.fromJson(Map<String, dynamic> json) => Occurrence(
        date: DateTime.parse(json['date']),
        vasche: json['vasche'],
      );
}
