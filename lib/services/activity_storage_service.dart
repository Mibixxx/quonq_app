import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/activity.dart';

class ActivityStorageService {
  ActivityStorageService._privateConstructor();
  static final ActivityStorageService instance =
      ActivityStorageService._privateConstructor();

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/activities.json');
  }

  Future<List<Activity>> loadActivities() async {
    final file = await _localFile;
    if (await file.exists()) {
      final contents = await file.readAsString();
      final List<dynamic> jsonData = jsonDecode(contents);
      return jsonData
          .map((json) => Activity.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<void> saveActivities(List<Activity> activities) async {
    final file = await _localFile;
    final jsonData = activities.map((a) => a.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonData));
  }

  Future<void> updateActivity(
      Activity updated, List<Activity> activities) async {
    final index = activities.indexWhere((a) => a.name == updated.name);
    if (index != -1) {
      activities[index] = updated;
      await saveActivities(activities);
    }
  }

  Future<void> deleteActivity(
      Activity toDelete, List<Activity> activities) async {
    activities.removeWhere((a) => a.name == toDelete.name);
    await saveActivities(activities);
  }
}
