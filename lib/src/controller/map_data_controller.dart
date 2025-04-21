import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:launch_map/src/consts.dart' as consts;
import 'package:launch_map/src/controller/launch_api_client.dart';
import 'package:launch_map/src/model/launch.dart';

/// Primary controller that manages the data and map behaviour
class MapDataController with ChangeNotifier {
  // Launches that are displayed on the map
  List<Launch> launches = [];

  // The launch that has been selected by the user from the list
  Launch? selectedLaunch;

  // used as a flag to show the circular loading indicator as required
  bool showLoading = false;

  // used to manage the map behaviour (e.g., move / rotate)
  MapController controller = MapController();

  // flag to enable auto selection of launches periodically
  bool autoPlayEnabled = false;

  // used to hold the current position in the launch array when auto play is enabled
  int currentAutoPlayerPosition = 0;

  // how many seconds are left until the API is called to refresh the data
  int secondsUntilRefresh = consts.secondsForDataRefresh;

  // hpw many seconds are left until the auto play moves to the next launch
  int timeUntilNextPOI = consts.timeUntilNextPOI;

  /// calls the launch event API and resets the [launches] variable to update the map
  Future<void> getLaunches() async {
    // turn on the loading circle
    showLoading = true;
    notifyListeners();

    // wait for the new launches to be updated
    launches = await LaunchAPIClient.getLaunches();
    // reset the countdown for refreshing the launch data
    secondsUntilRefresh = consts.secondsForDataRefresh;
    // deselect current selected launch
    selectedLaunch = null;
    // turn off the loading circle
    showLoading = false;
    notifyListeners();
  }

  /// starts the various countdowns on the app
  void startLaunchCountdown() {
    // every one second, execute this code
    Timer.periodic(const Duration(seconds: 1), (timer) {
      // update the launch countdown in all launches
      for (Launch launch in launches) {
        launch.updateTimeUntilLaunch();
      }
      // if auto player is on, take 1 second off the countdown
      if (autoPlayEnabled) {
        timeUntilNextPOI--;
        // if you've reached 0 - move to the next launch
        if (timeUntilNextPOI <= 0) {
          movePOI();
        }
      }
      // take 1 second off the data refresh countdown
      secondsUntilRefresh--;
      // if you've reached 0 - call the launch API to update the data
      if (secondsUntilRefresh <= 0) {
        getLaunches();
      }
      notifyListeners();
    });
  }

  /// sets the [selectedLaunch] variable
  void selectLaunch(Launch? launch) {
    selectedLaunch = launch;
    notifyListeners();
  }

  /// returns a list of markers for the map that represent the locations of the
  /// launch pads on the launch data from the API
  List<Marker> getMarkers() {
    return launches.map((launch) {
      return Marker(
        point: LatLng(launch.pad!.lat, launch.pad!.long),
        child: GestureDetector(
          onTap: () {},
          child: Column(
            children: [Icon(FontAwesomeIcons.rocket, color: Colors.white70)],
          ),
        ),
      );
    }).toList();
  }

  /// turns auto player on or off depending on current state
  void toggleAutoPlay() {
    autoPlayEnabled = !autoPlayEnabled;
    // if its just been turned on - select the current launch in the list and move the map to it
    if (autoPlayEnabled) {
      selectedLaunch = launches[currentAutoPlayerPosition];
      controller.move(
        LatLng(
          launches[currentAutoPlayerPosition].pad!.lat +
              consts.mapCoordOffsetForPanel,
          launches[currentAutoPlayerPosition].pad!.long,
        ),
        consts.zoomLevelWhenSelected,
      );
    }
    notifyListeners();
  }

  /// moves the auto play position to the next launch in the list
  void movePOI() {
    currentAutoPlayerPosition++;
    // if you have finished the list, move back to the first launch
    if (currentAutoPlayerPosition >= launches.length) {
      currentAutoPlayerPosition = 0;
    }
    controller.move(
      LatLng(
        launches[currentAutoPlayerPosition].pad!.lat +
            consts.mapCoordOffsetForPanel,
        launches[currentAutoPlayerPosition].pad!.long,
      ),
      consts.zoomLevelWhenSelected,
    );
    selectLaunch(launches[currentAutoPlayerPosition]);
    timeUntilNextPOI = consts.timeUntilNextPOI;
    notifyListeners();
  }
}
