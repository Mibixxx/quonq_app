import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../models/activity.dart';

Future<File> _getLocalFile() async {
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/activities.json');
}

Future<List<Activity>> loadActivities() async {
  final file = await _getLocalFile();
  if (await file.exists()) {
    final contents = await file.readAsString();
    final List<dynamic> jsonData = jsonDecode(contents);
    return jsonData
        .map((json) => Activity.fromJson(json as Map<String, dynamic>))
        .toList();
  } else {
    return [];
  }
}

Future<void> saveActivities(List<Activity> activities) async {
  final file = await _getLocalFile();
  final jsonData = activities.map((a) => a.toJson()).toList();
  await file.writeAsString(jsonEncode(jsonData));
}
