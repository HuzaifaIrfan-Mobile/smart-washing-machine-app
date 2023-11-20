import 'package:flutter/material.dart';

import 'dart:convert' as convert;
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'drawer.dart';

const WASHING_MACHINE_TASKS_LABEL = <String>[
  "Waiting",
  "Filling",
  "Washing",
  "Soaking",
  "Draining",
  "Drying",
  "Ending"
];

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var hostname = "192.168.10.225";
  TextEditingController hostnameController =
      TextEditingController(text: "hostname");

  bool is_running = false;
  bool is_hold = false;
  bool is_lid_closed = false;

  int task_sequence_pointer = 0;
  int task = 0;
  int count_down = 0;

  String message = "Not Connected";

  Timer? timer;

  _MyHomePageState() {
    Duration period = const Duration(seconds: 1);
    timer = Timer.periodic(period, (arg) {
      _refreshCurrentStatus();
    });
  }

  void loadHostname() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      hostname = (prefs.getString('hostname') ?? "192.168.10.225");
      hostnameController.text = hostname;
    });
  }

  void saveHostname() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      hostname = hostnameController.text;
      prefs.setString('hostname', hostname);
    });
  }

  @override
  void initState() {
    super.initState();
    loadHostname();
  }

  int toInt(bool val) {
    return val ? 1 : 0;
  }

  bool toBool(int val) {
    return val == 0 ? false : true;
  }

  void _refreshCurrentStatus() async {
    var url = Uri.http(hostname, '/current_status');

    // Await the http get response, then decode the json-formatted response.
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonResponse =
            convert.jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          // _current_status = jsonResponse.toString();
          is_running = toBool(jsonResponse["is_running"]);
          is_hold = toBool(jsonResponse["is_hold"]);
          is_lid_closed = toBool(jsonResponse["is_lid_closed"]);

          task_sequence_pointer = jsonResponse["task_sequence_pointer"];
          task = jsonResponse["task"];
          count_down = jsonResponse["count_down"];
          message = "Connected";
        });
        debugPrint('$jsonResponse');
      } else {
        debugPrint('Request failed with status: ${response.statusCode}.');
        setState(() {
          message = "Not Connected";
        });
      }
    } catch (e) {
      debugPrint('$e');
      setState(() {
        message = "Not Connected";
      });
    }
  }

  void _setNextTask(int tmp_task, int tmp_count_down) async {
    var url = Uri.http(hostname, '/next_washing_machine_task');

    List data = [tmp_task, tmp_count_down, 0, 0];
    //encode Map to JSON
    var body = json.encode(data);

    try {
      var response = await http.post(url,
          headers: {"Content-Type": "application/json"}, body: body);
      if (response.statusCode == 200) {
        var jsonResponse =
            convert.jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('$jsonResponse');
      } else {
        debugPrint('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  void _runMachine() async {
    var url = Uri.http(hostname, '/run');
    try {
      await http.get(url);
    } catch (e) {
      debugPrint('$e');
    }
  }

  void _pauseMachine() async {
    var url = Uri.http(hostname, '/pause');
    try {
      await http.get(url);
    } catch (e) {
      debugPrint('$e');
    }
  }

  void _holdMachine() async {
    var url = Uri.http(hostname, '/hold');
    try {
      await http.get(url);
    } catch (e) {
      debugPrint('$e');
    }
  }

  void _skipMachine() async {
    var url = Uri.http(hostname, '/skip');
    try {
      await http.get(url);
    } catch (e) {
      debugPrint('$e');
    }
  }

  void _resetMachine() async {
    var url = Uri.http(hostname, '/reset');
    try {
      await http.get(url);
    } catch (e) {
      debugPrint('$e');
    }
  }

  void _restartMachine() async {
    var url = Uri.http(hostname, '/restart');
    try {
      await http.get(url);
    } catch (e) {
      debugPrint('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: NavDrawer(
        restartMachine: () => _restartMachine(),
        setNextTask: _setNextTask,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'hostname',
              ),
              controller: hostnameController,
            ),
            FloatingActionButton(
              onPressed: saveHostname,
              tooltip: 'save',
              child: const Icon(Icons.save),
            ),
            Text(
              message,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              WASHING_MACHINE_TASKS_LABEL[task],
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              "$count_down",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              "Sequence: $task_sequence_pointer",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              "Run: $is_running",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              "Hold: $is_hold",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              "Lid Closed: $is_lid_closed",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ButtonBar(
                  children: [
                    FloatingActionButton(
                      onPressed: _runMachine,
                      tooltip: 'Run',
                      child: const Icon(Icons.play_arrow),
                    ),
                    FloatingActionButton(
                      onPressed: _pauseMachine,
                      tooltip: 'Pause',
                      child: const Icon(Icons.stop),
                    ),
                    FloatingActionButton(
                      onPressed: _holdMachine,
                      tooltip: 'Hold',
                      child: const Icon(Icons.pause),
                    ),
                    FloatingActionButton(
                      onPressed: _skipMachine,
                      tooltip: 'Skip',
                      child: const Icon(Icons.skip_next),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ButtonBar(
                  children: [
                    FloatingActionButton(
                      onPressed: _refreshCurrentStatus,
                      tooltip: 'Refresh',
                      child: const Icon(Icons.refresh),
                    ),
                    FloatingActionButton(
                      onPressed: _resetMachine,
                      tooltip: 'Reset',
                      child: const Icon(Icons.reset_tv),
                    ),
                    // FloatingActionButton(
                    //   onPressed: () => {_setNextTask(3, 60)},
                    //   tooltip: 'Restart',
                    //   child: const Icon(Icons.restart_alt),
                    // ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
