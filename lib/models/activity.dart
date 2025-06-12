import "../models/occurrence.dart";

class Activity {
  String name;
  List<Occurrence> occurrences;

  Activity({required this.name, List<Occurrence>? occurrences})
      : occurrences = occurrences ?? [];

  int get count => occurrences.length;

  Map<String, dynamic> toJson() => {
        'name': name,
        'occurrences': occurrences.map((e) => e.toJson()).toList(),
      };

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        name: json['name'],
        occurrences: (json['occurrences'] as List).map((e) {
          if (e is String) {
            // formato vecchio: solo una stringa con la data
            return Occurrence(date: DateTime.parse(e));
          } else if (e is Map<String, dynamic>) {
            // nuovo formato: mappa con data + vasche
            return Occurrence.fromJson(e);
          } else {
            throw Exception("Formato di occorrenza non valido");
          }
        }).toList(),
      );
}
