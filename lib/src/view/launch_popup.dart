import 'package:flutter/material.dart';
import 'package:launch_map/src/consts.dart' as consts;
import 'package:launch_map/src/controller/map_data_controller.dart';
import 'package:launch_map/src/view/countdown.dart';
import 'package:provider/provider.dart';

import '../model/launch.dart';

/// Graphical widget that represents a popup on the map when the user selects
/// a launch.
class LaunchPopup extends StatelessWidget {
  const LaunchPopup({super.key, required this.launch});

  final Launch launch;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        TooltipShape(
          color: Colors.white,
          borderRadius: 10,
          arrowHeight: 15,
          arrowWidth: 30,
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      launch.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Countdown(
                          timeToLaunch: launch.timeToLaunch!,
                          launched: launch.launched,
                          lightMode: true,
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          margin: EdgeInsets.only(right: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(launch.status!.name),
                        ),
                      ],
                    ),
                    LaunchWindow(
                      windowStart: launch.windowStart!,
                      windowEnd: launch.windowEnd!,
                      launchTime: launch.launchTime!,
                    ),
                    Text("Pad", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("${launch.pad!.name}, ${launch.pad!.country}"),
                    const SizedBox(height: 10),
                    Text(
                      "Mission",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      launch.mission!.description,
                      softWrap: true,
                      maxLines: 7,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Image.network(
                  height: double.infinity,
                  width: double.infinity,
                  launch.imageUrl!,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.cancel_outlined),
          onPressed: () {
            MapDataController mapDataController =
                Provider.of<MapDataController>(context, listen: false);
            mapDataController.selectLaunch(null);
          },
        ),
      ],
    );
  }
}

/// Custom graphical widget that provides a tooltip shape with a downward arrow
/// in the bottom centre
class TooltipShape extends StatelessWidget {
  final Widget child;
  final Color color;
  final double arrowHeight;
  final double arrowWidth;
  final double borderRadius;

  const TooltipShape({
    Key? key,
    required this.child,
    this.color = Colors.grey,
    this.arrowHeight = 10.0,
    this.arrowWidth = 20.0,
    this.borderRadius = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Rounded container
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            width: 850,
            height: 400,
            color: color,
            padding: const EdgeInsets.all(8.0),
            child: child,
          ),
        ),
        // Triangle marker
        CustomPaint(
          size: Size(arrowWidth, arrowHeight),
          painter: _TrianglePainter(color),
        ),
      ],
    );
  }
}

/// Custom painter that provides a downward facing arrow used as the triangle
/// at the bottom of the tooltip.
class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final path =
        Path()
          ..moveTo(0, 0)
          ..lineTo(size.width, 0)
          ..lineTo(size.width / 2, size.height)
          ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Custom graphical widget that shows the [windowStart] and [windowEnd] values
/// with a slide between representing where the predicted launch time is within
/// this window.
class LaunchWindow extends StatelessWidget {
  const LaunchWindow({
    super.key,
    required this.windowStart,
    required this.windowEnd,
    required this.launchTime,
  });

  final DateTime windowStart;
  final DateTime windowEnd;
  final DateTime launchTime;

  final double sliderWidth = 300;

  /// returns a value between 0 and 1 representing a % of where the predicted launch
  /// time sits between a given window. e.g., a 10 hour window with a launch on hour 5 would return 0.5 (for 50%)
  double getLaunchWindowSplit() {
    int secondsInPeriod = windowStart.difference(windowEnd).inSeconds;
    int secondsToLaunchTime = windowStart.difference(launchTime).inSeconds;
    // if the launch window period is 0 for any reason then return 0.5.
    if (secondsInPeriod == 0) {
      return 0.5;
    }
    return secondsToLaunchTime / secondsInPeriod;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Text(
            "${windowStart.day.toString().padLeft(2, '0')}/${windowStart.month.toString().padLeft(2, '0')} - ${windowStart.hour.toString().padLeft(2, '0')}:${windowStart.minute.toString().padLeft(2, '0')}",
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Slider(
                value: getLaunchWindowSplit(),
                onChanged: (double value) {},
                activeColor: consts.primaryColor,
                inactiveColor: Colors.grey.withOpacity(0.4),
                thumbColor: consts.primaryColor,
              ),
              Text(
                "${launchTime.day.toString().padLeft(2, '0')}/${launchTime.month.toString().padLeft(2, '0')} - ${launchTime.hour.toString().padLeft(2, '0')}:${launchTime.minute.toString().padLeft(2, '0')}",
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Text(
            "${windowEnd.day.toString().padLeft(2, '0')}/${windowEnd.month.toString().padLeft(2, '0')} - ${windowEnd.hour.toString().padLeft(2, '0')}:${windowEnd.minute.toString().padLeft(2, '0')}",
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
