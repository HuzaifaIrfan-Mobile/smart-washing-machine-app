import 'package:flutter/material.dart';
import 'settings/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'LABELS.dart';

import 'package:percent_indicator/circular_percent_indicator.dart';

class WashingMachineScreen extends StatefulWidget {
  const WashingMachineScreen({super.key});
  @override
  State<WashingMachineScreen> createState() => WashingMachineScreenState();
}

class WashingMachineScreenState extends State<WashingMachineScreen> {
  var hostname = "192.168.10.225";

  bool isRunning = false;
  bool isHold = false;
  bool isLidClosed = false;

  int taskSequencePointer = 0;
  int task = 0;
  String taskLabel = "empty";
  int countDown = 0;

  String message = "Not Connected";

  Timer? timer;

  WashingMachineScreenState() {
    Duration period = const Duration(seconds: 1);
    timer = Timer.periodic(period, (arg) {
      refreshCurrentStatus();
    });
  }

  @override
  void initState() {
    super.initState();
    loadHostname();
    // debugPrint('WashingMachineScreen');
  }

  void loadHostname() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      hostname = (prefs.getString('hostname') ?? "192.168.10.225");
    });
    debugPrint("Loaded Hostname: $hostname");
  }

  void openSettingsScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
    if (result != null) {
      debugPrint("Returned Hostname: $result");
    }
    loadHostname();
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
          taskLabel = washingMachineTasksLabel[task];
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
                    onPressed: openSettingsScreen,
                    tooltip: 'Open Settings Screen',
                    child: const Icon(Icons.settings),
                  ),
                ],
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
                        "$countDown s\n$taskLabel",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        cardMenu(
                          icon: 'assets/images/energy.png',
                          title: 'ENERGY',
                        ),
                        cardMenu(
                          onTap: skipMachine,
                          // onTap: () {
                          //   Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) => const TemperaturePage(),
                          //     ),
                          //   );
                          // },
                          icon: 'assets/images/temperature.png',
                          title: 'TEMPERATURE',
                          color: Colors.indigoAccent,
                          fontColor: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        cardMenu(
                          icon: 'assets/images/water.png',
                          title: 'WATER',
                        ),
                        cardMenu(
                          icon: 'assets/images/entertainment.png',
                          title: 'ENTERTAINMENT',
                        ),
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

    // @override
    // Widget build(BuildContext context) {
    //   return Scaffold(
    //     appBar: AppBar(
    //       title: const Text('Washing Machine'),
    //     ),
    //     body: Center(
    //       child: Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         children: [
    //           ElevatedButton(
    //             onPressed: openSettingsScreen,
    //             child: const Text('Settings'),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // }
  }
}

Widget cardMenu({
  required String title,
  required String icon,
  VoidCallback? onTap,
  Color color = Colors.white,
  Color fontColor = Colors.grey,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(
        vertical: 36,
      ),
      width: 156,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Image.asset(icon),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: fontColor),
          )
        ],
      ),
    ),
  );
}
