import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:launch_map/src/consts.dart' as consts;
import 'package:launch_map/src/controller/map_data_controller.dart';
import 'package:launch_map/src/model/launch.dart';
import 'package:launch_map/src/view/launch_popup.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:js' as js;

import 'launch_card.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapDataController mapDataController;

  bool dataLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mapDataController = context.watch<MapDataController>();
    // if data has not been loaded - call API on app start.
    if (!dataLoaded) {
      mapDataController.getLaunches();
      mapDataController.startLaunchCountdown();
      dataLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(flex: 7, child: MyMap()),
          Expanded(
            flex: 2,
            child: Container(
              height: double.infinity,
              padding: EdgeInsets.all(8),
              color: consts.primaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          mapDataController.autoPlayEnabled
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          mapDataController.toggleAutoPlay();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.refresh, color: Colors.white),
                        onPressed: () {
                          mapDataController.getLaunches();
                        },
                      ),
                      Expanded(child: Container()),
                      Text(
                        "Refreshing data in: ${mapDataController.secondsUntilRefresh}",
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const Divider(),
                  Text(
                    "Upcoming Launches",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        ListView.builder(
                          itemCount: mapDataController.launches.length,
                          itemBuilder: (context, index) {
                            Launch selectedLaunch =
                                mapDataController.launches[index];
                            return LaunchCard(
                              launch: selectedLaunch,
                              mapController: mapDataController.controller,
                              isSelected:
                                  mapDataController.selectedLaunch ==
                                  selectedLaunch,
                            );
                          },
                        ),
                        Visibility(
                          visible: mapDataController.showLoading,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),

                  Row(
                    children: [
                      const Text(
                        "API provided by: ",
                        style: TextStyle(color: Colors.white),
                      ),
                      InkWell(
                        onTap:
                            () => launchUrl(
                              Uri.parse('https://thespacedevs.com/'),
                            ),
                        child: Text(
                          'https://thespacedevs.com/',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom map widget that uses the flutter_map library to return a map for this application
class MyMap extends StatefulWidget {
  const MyMap({super.key});

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  late MapDataController mapDataController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mapDataController = context.watch<MapDataController>();
  }

  /// returns a builder that sets tiles to a custom dark theme
  Widget _darkModeTileBuilder(
    BuildContext context,
    Widget tileWidget,
    TileImage tile,
  ) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        -0.215, -0.72, -0.075, 0, 250, // Red channel - slightly reduced
        -0.215, -0.72, -0.075, 0, 252, // Green channel - slightly reduced
        -0.205,
        -0.70,
        -0.06,
        0,
        260, // Blue channel - just a touch more emphasis
        0, 0, 0, 1, 0, // Alpha channel
      ]),
      child: tileWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapDataController.controller,
      options: MapOptions(
        initialCenter: LatLng(0, 0), // Center the map over London
        initialZoom: 2,
      ),
      children: [
        TileLayer(
          // Bring your own tiles
          urlTemplate:
              'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // For demonstration only
          userAgentPackageName: 'com.example.app', // Add your app identifier
          tileBuilder: _darkModeTileBuilder,
          tileProvider: CancellableNetworkTileProvider(),
        ),
        MarkerLayer(markers: mapDataController.getMarkers()),
        mapDataController.selectedLaunch != null
            ? MarkerLayer(
              alignment: Alignment.topCenter,
              markers: [
                Marker(
                  height: 430,
                  width: 850,
                  point: LatLng(
                    mapDataController.selectedLaunch!.pad!.lat,
                    mapDataController.selectedLaunch!.pad!.long,
                  ),
                  child: LaunchPopup(launch: mapDataController.selectedLaunch!),
                ),
              ],
            )
            : MarkerLayer(markers: []),
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              onTap: () {
                js.context.callMethod('open', [
                  'https://openstreetmap.org/copyright',
                ]);
              },
            ),
          ],
        ),
      ],
    );
  }
}
