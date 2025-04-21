import 'package:flutter/material.dart';

/// Graphical widget that shows the days/hours/minutes/seconds until launch
/// based on a given duration: [timeToLaunch]
class Countdown extends StatelessWidget {
  Countdown({
    super.key,
    required this.timeToLaunch,
    required this.launched,
    this.lightMode = false,
  });

  final Duration
  timeToLaunch; // time until the launch - drives the countdown values
  final bool launched; // has the launch taken place? if true, T- becomes T+
  final bool lightMode; // used to visualise the widget slightly differently.

  late final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    labelStyle = TextStyle(
      fontSize: 8,
      color: lightMode ? Colors.black87 : Colors.white30,
    );
    return Row(
      spacing: 8,
      children: [
        Text(
          "T ${launched ? "+" : "-"}",
          style: TextStyle(
            fontSize: 22,
            color: lightMode ? Colors.black54 : Colors.white30,
          ),
        ),
        Column(
          children: [
            Digit(number: timeToLaunch.inDays, lightMode: lightMode),
            Text("Days", style: labelStyle),
          ],
        ),
        Column(
          children: [
            Digit(number: timeToLaunch.inHours % 24, lightMode: lightMode),
            Text("Hours", style: labelStyle),
          ],
        ),
        Column(
          children: [
            Digit(number: timeToLaunch.inMinutes % 60, lightMode: lightMode),
            Text("Minutes", style: labelStyle),
          ],
        ),
        Column(
          children: [
            Digit(number: timeToLaunch.inSeconds % 60, lightMode: lightMode),
            Text("Seconds", style: labelStyle),
          ],
        ),
      ],
    );
  }
}

class Digit extends StatelessWidget {
  Digit({super.key, required this.number, required this.lightMode});

  final int number;
  final bool lightMode;

  late final TextStyle digitTextStyle;

  @override
  Widget build(BuildContext context) {
    digitTextStyle = TextStyle(
      fontSize: 28,
      color: lightMode ? Colors.black87 : Colors.white60,
    );
    String formattedNumber = number.toString().padLeft(2, '0');
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.withOpacity(0.5), Colors.grey.withOpacity(0.2)],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(formattedNumber, style: digitTextStyle),
    );
  }
}
