import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'labels.dart';

import 'settings/defaults.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WashingMachine {
  /// private constructor
  WashingMachine._();

  /// the one and only instance of this singleton
  static final instance = WashingMachine._();

  var hostname = defaultHostname;
  var fillingTaskCountdown = defaultFillingTaskCountdown;
  var washingTaskCountdown = defaultWashingTaskCountdown;
  var soakingTaskCountdown = defaultSoakingTaskCountdown;
  var drainingTaskCountdown = defaultDrainingTaskCountdown;
  var dryingTaskCountdown = defaultDryingTaskCountdown;

  bool isRunning = false;
  bool isHold = false;
  bool isLidClosed = false;

  int taskSequencePointer = 0;
  int task = 0;
  String centerLabel = "Status";
  int countDown = 0;

  List<List<int>> taskSequence = [
    [0, 60, 0, 0],
    [0, 60, 0, 0],
    [0, 60, 0, 0],
    [0, 60, 0, 0],
    [0, 60, 0, 0],
    [0, 60, 0, 0],
    [0, 60, 0, 0],
    [0, 60, 0, 0],
    [0, 60, 0, 0],
    [0, 60, 0, 0],
    [0, 60, 0, 0],
    [0, 60, 0, 0],
    [0, 60, 0, 0],
    [0, 60, 0, 0],
    [0, 60, 0, 0],
    [0, 60, 0, 0],
  ];

  String message = "Not Connected";

  void loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    hostname = (prefs.getString('hostname') ?? defaultHostname);

    fillingTaskCountdown = (prefs.getString('fillingTaskCountdown') ??
        defaultFillingTaskCountdown);
    washingTaskCountdown = (prefs.getString('washingTaskCountdown') ??
        defaultWashingTaskCountdown);
    soakingTaskCountdown = (prefs.getString('soakingTaskCountdown') ??
        defaultSoakingTaskCountdown);
    drainingTaskCountdown = (prefs.getString('drainingTaskCountdown') ??
        defaultDrainingTaskCountdown);
    dryingTaskCountdown =
        (prefs.getString('dryingTaskCountdown') ?? defaultDryingTaskCountdown);

    debugPrint("Loaded hostname: $hostname");

    debugPrint("Loaded fillingTaskCountdown: $fillingTaskCountdown");
    debugPrint("Loaded washingTaskCountdown: $washingTaskCountdown");
    debugPrint("Loaded soakingTaskCountdown: $soakingTaskCountdown");
    debugPrint("Loaded drainingTaskCountdown: $drainingTaskCountdown");
    debugPrint("Loaded dryingTaskCountdown: $dryingTaskCountdown");
  }

  void saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('hostname', hostname);

    prefs.setString('fillingTaskCountdown', fillingTaskCountdown);
    prefs.setString('washingTaskCountdown', washingTaskCountdown);
    prefs.setString('soakingTaskCountdown', soakingTaskCountdown);
    prefs.setString('drainingTaskCountdown', drainingTaskCountdown);
    prefs.setString('dryingTaskCountdown', dryingTaskCountdown);

    debugPrint("Saved hostname: $hostname");

    debugPrint("Saved fillingTaskCountdown: $fillingTaskCountdown");
    debugPrint("Saved washingTaskCountdown: $washingTaskCountdown");
    debugPrint("Saved soakingTaskCountdown: $soakingTaskCountdown");
    debugPrint("Saved drainingTaskCountdown: $drainingTaskCountdown");
    debugPrint("Saved dryingTaskCountdown: $dryingTaskCountdown");

    loadSettings();
  }

  void getTaskSequence() async {
    var url = Uri.http(hostname, '/current_task_sequence');

    // Await the http get response, then decode the json-formatted response.
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

        taskSequencePointer = jsonResponse["task_sequence_pointer"];

        var tmpTaskSequence = jsonResponse["task_sequence"];

        for (int i = 0; i < 16; i++) {
          for (int j = 0; j < 4; j++) {
            taskSequence[i][j] = tmpTaskSequence[i][j];
          }
        }

        debugPrint('$jsonResponse');
      } else {
        debugPrint('Request failed with status: ${response.statusCode}.');

        debugPrint("Cant Get Task Sequence");
      }
    } catch (e) {
      debugPrint('$e');
      debugPrint("Cant Get Task Sequence");
    }
  }

  void setTaskSequence(List tmpTaskSequence) async {
    var url = Uri.http(hostname, '/change_washing_machine_task_sequence');

    // List data = [tmpTask, tmpCountDown, 0, 0];
    //  List<List<int>> tmpTaskSequence = [
    //   [0, 60, 0, 0],
    //   [0, 60, 0, 0],
    //   [0, 60, 0, 0],
    //   [0, 60, 0, 0],
    //   [0, 60, 0, 0],
    //   [0, 60, 0, 0],
    //   [0, 60, 0, 0],
    //   [0, 60, 0, 0],
    //   [0, 60, 0, 0],
    //   [0, 60, 0, 0],
    //   [0, 60, 0, 0],
    //   [0, 60, 0, 0],
    //   [0, 60, 0, 0],
    //   [0, 60, 0, 0],
    //   [0, 60, 0, 0],
    //   [0, 60, 0, 0]
    // ];

    //encode Map to JSON
    var body = json.encode(tmpTaskSequence);

    try {
      var response = await http.post(url,
          headers: {"Content-Type": "application/json"}, body: body);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('$jsonResponse');
      } else {
        debugPrint('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  void setNextTask(
      {int task = 0, int countdown = 60, int val1 = 0, int val2 = 0}) async {
    var url = Uri.http(hostname, '/next_washing_machine_task');

    List data = [task, countdown, val1, val2];
    //encode Map to JSON
    var body = json.encode(data);

    try {
      var response = await http.post(url,
          headers: {"Content-Type": "application/json"}, body: body);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('$jsonResponse');
      } else {
        debugPrint('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  void runMachine() async {
    var url = Uri.http(hostname, '/run');
    try {
      await http.get(url);
    } catch (e) {
      debugPrint('$e');
    }
  }

  void pauseMachine() async {
    var url = Uri.http(hostname, '/pause');
    try {
      await http.get(url);
    } catch (e) {
      debugPrint('$e');
    }
  }

  void holdMachine() async {
    var url = Uri.http(hostname, '/hold');
    try {
      await http.get(url);
    } catch (e) {
      debugPrint('$e');
    }
  }

  void skipMachine() async {
    var url = Uri.http(hostname, '/skip');
    try {
      await http.get(url);
    } catch (e) {
      debugPrint('$e');
    }
  }

  void resetMachine() async {
    var url = Uri.http(hostname, '/reset');
    try {
      await http.get(url);
    } catch (e) {
      debugPrint('$e');
    }
  }

  void restartMachine() async {
    var url = Uri.http(hostname, '/restart');
    try {
      await http.get(url);
    } catch (e) {
      debugPrint('$e');
    }
  }

  int toInt(bool val) {
    return val ? 1 : 0;
  }

  bool toBool(int val) {
    return val == 0 ? false : true;
  }

  void refreshCurrentStatus() async {
    var url = Uri.http(hostname, '/current_status');

    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        isRunning = toBool(jsonResponse["is_running"]);
        isHold = toBool(jsonResponse["is_hold"]);
        isLidClosed = toBool(jsonResponse["is_lid_closed"]);

        taskSequencePointer = jsonResponse["task_sequence_pointer"];
        task = jsonResponse["task"];

        var taskLabel = washingMachineTasksLabel[task];
        var runningLabel = isRunning
            ? isHold
                ? "Hold"
                : "Running"
            : "Paused";
        var lidLabel = isLidClosed ? "Closed" : "Open";

        centerLabel =
            "$countDown s\n$taskSequencePointer->$taskLabel\n$runningLabel\n$lidLabel";

        countDown = jsonResponse["count_down"];
        message = "Connected";
        debugPrint('$jsonResponse');
      } else {
        debugPrint('Request failed with status: ${response.statusCode}.');

        message = "Not Connected";

        debugPrint(message);
      }
    } catch (e) {
      debugPrint('$e');

      message = "Not Connected";

      debugPrint(message);
    }
  }
}
