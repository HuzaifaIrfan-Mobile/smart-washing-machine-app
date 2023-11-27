import 'package:flutter/material.dart';
import 'settings/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'labels.dart';

import 'settings/defaults.dart';

import 'package:percent_indicator/circular_percent_indicator.dart';

class WashingMachineScreen extends StatefulWidget {
  const WashingMachineScreen({super.key});
  @override
  State<WashingMachineScreen> createState() => WashingMachineScreenState();
}

class WashingMachineScreenState extends State<WashingMachineScreen> {
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

  String message = "Not Connected";

  Timer? timer;

  WashingMachineScreenState() {
    setupRefreshCurrentStatusTimer();
  }

  void setupRefreshCurrentStatusTimer() {
    Duration period = const Duration(seconds: 1);
    timer = Timer.periodic(period, (arg) {
      refreshCurrentStatus();
    });
  }

  void cancelRefreshCurrentStatusTimer() {
    timer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    loadSettings();
    // debugPrint('WashingMachineScreen');
  }

  void loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      hostname = (prefs.getString('hostname') ?? defaultHostname);

      fillingTaskCountdown = (prefs.getString('fillingTaskCountdown') ??
          defaultFillingTaskCountdown);

      washingTaskCountdown = (prefs.getString('washingTaskCountdown') ??
          defaultWashingTaskCountdown);

      soakingTaskCountdown = (prefs.getString('soakingTaskCountdown') ??
          defaultSoakingTaskCountdown);

      drainingTaskCountdown = (prefs.getString('drainingTaskCountdown') ??
          defaultDrainingTaskCountdown);

      dryingTaskCountdown = (prefs.getString('dryingTaskCountdown') ??
          defaultDryingTaskCountdown);
    });
    debugPrint("Loaded hostname: $hostname");

    debugPrint("Loaded fillingTaskCountdown: $fillingTaskCountdown");
    debugPrint("Loaded washingTaskCountdown: $washingTaskCountdown");
    debugPrint("Loaded soakingTaskCountdown: $soakingTaskCountdown");
    debugPrint("Loaded drainingTaskCountdown: $drainingTaskCountdown");
    debugPrint("Loaded dryingTaskCountdown: $dryingTaskCountdown");
  }

  void openSettingsScreen() async {
    pauseMachine();
    cancelRefreshCurrentStatusTimer();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
    if (result != null) {
      debugPrint("Returned Hostname: $result");
    }
    loadSettings();
    setupRefreshCurrentStatusTimer();
  }

  int toInt(bool val) {
    return val ? 1 : 0;
  }

  bool toBool(int val) {
    return val == 0 ? false : true;
  }

  void refreshCurrentStatus() async {
    var url = Uri.http(hostname, '/current_status');

    // Await the http get response, then decode the json-formatted response.
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          // _current_status = jsonResponse.toString();
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
        });
        debugPrint('$jsonResponse');
      } else {
        debugPrint('Request failed with status: ${response.statusCode}.');
        setState(() {
          message = "Not Connected";
        });
        debugPrint(message);
      }
    } catch (e) {
      debugPrint('$e');
      setState(() {
        message = "Not Connected";
      });
      debugPrint(message);
    }
  }

  void setNextTask(int tmpTask, int tmpCountDown) async {
    var url = Uri.http(hostname, '/next_washing_machine_task');

    List data = [tmpTask, tmpCountDown, 0, 0];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 18, left: 24, right: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'HI MOM',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FloatingActionButton(
                    heroTag: "openSettings",
                    onPressed: openSettingsScreen,
                    tooltip: 'Open Settings Screen',
                    child: const Icon(Icons.settings),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(height: 24),
                    CircularPercentIndicator(
                      radius: 150,
                      lineWidth: 24,
                      percent: 1,
                      progressColor: Colors.indigo,
                      center: Text(
                        centerLabel,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FloatingActionButton(
                          heroTag: "runMachine",
                          onPressed: runMachine,
                          tooltip: 'Run',
                          child: const Icon(Icons.play_arrow),
                        ),
                        FloatingActionButton(
                          heroTag: "pauseMachine",
                          onPressed: pauseMachine,
                          tooltip: 'Pause',
                          child: const Icon(Icons.stop),
                        ),
                        FloatingActionButton(
                          heroTag: "holdMachine",
                          onPressed: holdMachine,
                          tooltip: 'Hold',
                          child: const Icon(Icons.pause),
                        ),
                        FloatingActionButton(
                          heroTag: "skipMachine",
                          onPressed: skipMachine,
                          tooltip: 'Skip',
                          child: const Icon(Icons.skip_next),
                        ),
                        FloatingActionButton(
                          heroTag: "resetMachine",
                          onPressed: resetMachine,
                          tooltip: 'Reset',
                          child: const Icon(Icons.reset_tv),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        imageIconButtons(
                            onPressed: () => {
                                  setNextTask(
                                      1, int.parse(fillingTaskCountdown))
                                },
                            text: "Fill",
                            icon: "filling.png"),
                        imageIconButtons(
                            onPressed: () => {
                                  setNextTask(
                                      2, int.parse(washingTaskCountdown))
                                },
                            text: "Wash",
                            icon: "washing.png"),
                        imageIconButtons(
                            onPressed: () => {
                                  setNextTask(
                                      3, int.parse(soakingTaskCountdown))
                                },
                            text: "Soak",
                            icon: "soaking.png"),
                        imageIconButtons(
                            onPressed: () => {
                                  setNextTask(
                                      4, int.parse(drainingTaskCountdown))
                                },
                            text: "Drain",
                            icon: "draining.png"),
                        imageIconButtons(
                            onPressed: () => {
                                  setNextTask(5, int.parse(dryingTaskCountdown))
                                },
                            text: "Dry",
                            icon: "drying.png"),
                      ],
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget imageIconButtons({
  required String text,
  required String icon,
  VoidCallback? onPressed,
}) {
  return FloatingActionButton(
    heroTag: "DryingTask",
    onPressed: onPressed,
    tooltip: 'Drying',
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ImageIcon(
          AssetImage("assets/$icon"),
          size: 24,
        ),
        Text(text), // <-- Text
      ],
    ),
  );
}
