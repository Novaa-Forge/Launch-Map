import 'package:launch_map/src/model/launch_service_provider.dart';
import 'package:launch_map/src/model/launch_status.dart';
import 'package:launch_map/src/model/pad.dart';
import 'package:launch_map/src/model/rocket.dart';

import 'mission.dart';

/// Class represents a launch object in the application.
/// An array of launches in a json response from the API are converted into a list
/// of these objects.
class Launch {
  String id;
  String url;
  String name;
  String launchDesignator;
  LaunchStatus? status;
  DateTime? windowStart;
  DateTime? windowEnd;
  DateTime? launchTime; //net
  String? imageUrl;
  String? thumbnailUrl;
  String? credit;
  int? probability;
  LaunchServiceProvider? launchServiceProvider;
  Rocket? rocket;
  Mission? mission;
  Pad? pad;
  Duration? timeToLaunch;
  bool launched = false;

  Launch({
    required this.id,
    required this.url,
    required this.name,
    required this.launchDesignator,
    required this.status,
    required this.windowStart,
    required this.windowEnd,
    required this.launchTime,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.credit,
    required this.probability,
    required this.launchServiceProvider,
    required this.rocket,
    required this.mission,
    required this.pad,
  });

  // build a launch from a json
  factory Launch.fromJson(Map<String, dynamic> json) {
    return Launch(
      id: json['id'],
      url: json['url'] ?? "",
      name: json['name'],
      launchDesignator: json['launch_designator'] ?? "",
      status: LaunchStatus.fromJson(json['status']),
      windowStart: DateTime.parse(json['window_start']),
      windowEnd: DateTime.parse(json['window_end']),
      launchTime: DateTime.parse(json['net']),
      imageUrl: json['image'] != null ? json['image']['image_url'] : null,
      thumbnailUrl:
          json['image'] != null ? json['image']['thumbnail_url'] : null,
      credit: json['image'] != null ? json['image']['credit'] : null,
      probability: json['probability'],
      launchServiceProvider: LaunchServiceProvider.fromJson(
        json['launch_service_provider'],
      ),
      rocket: json['rocket'] != null ? Rocket.fromJson(json['rocket']) : null,
      mission:
          json['mission'] != null ? Mission.fromJson(json['mission']) : null,
      pad: json['pad'] != null ? Pad.fromJson(json['pad']) : null,
    );
  }

  /// update the time to launch value based on the current time and the planned launch time
  void updateTimeUntilLaunch() {
    DateTime currentTime = DateTime.now();
    timeToLaunch = launchTime!.difference(currentTime);
    if (timeToLaunch! < Duration(seconds: 0)) {
      timeToLaunch = timeToLaunch! * -1;
      launched = true;
    }
  }
}
