import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:launch_map/src/view/countdown.dart';
import 'package:provider/provider.dart';

import '../consts.dart' as consts;
import '../controller/map_data_controller.dart';
import '../model/launch.dart';

/// Graphical widget that shows the title of a launch along with a countdown
/// Used to populate the list on the right hand side of the dashboard
class LaunchCard extends StatelessWidget {
  const LaunchCard({
    Key? key,
    required this.launch,
    required this.mapController,
    required this.isSelected,
  }) : super(key: key);

  final Launch launch;
  final MapController mapController;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    MapDataController mapDataController = context.watch<MapDataController>();
    return Card(
      color: isSelected ? Colors.white24 : consts.secondaryColor,
      shape:
          isSelected
              ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.white),
              )
              : null,
      child: ListTile(
        onTap: () {
          mapController.move(
            LatLng(
              launch.pad!.lat + consts.mapCoordOffsetForPanel,
              launch.pad!.long,
            ),
            consts.zoomLevelWhenSelected,
          );
          mapDataController.selectLaunch(launch);
        },
        title: Text(launch.name, style: TextStyle(color: Colors.white60)),
        subtitle: Countdown(
          timeToLaunch: launch.timeToLaunch ?? Duration(seconds: 0),
          launched: launch.launched,
        ),
      ),
    );
  }
}
