import 'dart:convert';
import 'package:launch_map/src/consts.dart' as consts;
import 'package:launch_map/src/model/launch.dart';
import 'package:http/http.dart' as http;

/// Static class used to call launch API
class LaunchAPIClient {
  // can be increased to receive more results from the endpoint
  static int maxCallCycles = 1;

  /// Calls the launches/upcoming API
  static Future<List<Launch>> getLaunches() async {
    // url - passes [limit] argument which dictates how many launch resposnes should be returned
    String requestUrl =
        "https://ll.thespacedevs.com/2.3.0/launches/upcoming/?limit=${consts.apiLimit}";

    // used to calculate how many times the API is called, can be used for "get next x" functionality
    int callCycle = 0;

    // create empty list, will be populated by the API response, this will be returned
    List<Launch> launches = [];

    // while your within your call cycles (we have this set to 1 only)
    while (callCycle < maxCallCycles) {
      callCycle++;
      // wait for response
      http.Response response = await http.get(Uri.parse(requestUrl));
      // turn response into a map/json
      Map<dynamic, dynamic> responseAsJson = jsonDecode(response.body);
      // loop through the json results and transform them into Launch objects
      for (int i = 0; i < responseAsJson['results'].length; i++) {
        launches.add(Launch.fromJson(responseAsJson['results'][i]));
      }

      // update the request url for the next set of results if using this functionality
      requestUrl = responseAsJson['next'];
    }

    return launches;
  }
}
