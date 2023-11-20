import 'package:flutter/material.dart';

import 'dart:convert' as convert;

import 'package:http/http.dart' as http;

const hostname = "192.168.10.235";

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _current_status = "";

  void _refreshCurrentStatus() async {
    var url = Uri.http(hostname, '/current_status');

    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      setState(() {
        _current_status = jsonResponse.toString();
      });
      debugPrint('$jsonResponse');
    } else {
      debugPrint('Request failed with status: ${response.statusCode}.');
    }
  }

  void _runMachine() async {
    var url = Uri.http(hostname, '/run');
    await http.get(url);
  }

  void _pauseMachine() async {
    var url = Uri.http(hostname, '/pause');
    await http.get(url);
  }

  void _holdMachine() async {
    var url = Uri.http(hostname, '/hold');
    await http.get(url);
  }

  void _skipMachine() async {
    var url = Uri.http(hostname, '/skip');
    await http.get(url);
  }

  void _resetMachine() async {
    var url = Uri.http(hostname, '/reset');
    await http.get(url);
  }

  void _restartMachine() async {
    var url = Uri.http(hostname, '/restart');
    await http.get(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _current_status,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: _resetMachine,
                  tooltip: 'Reset',
                  child: const Icon(Icons.reset_tv),
                ),
                FloatingActionButton(
                  onPressed: _restartMachine,
                  tooltip: 'Restart',
                  child: const Icon(Icons.restart_alt),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshCurrentStatus,
        tooltip: 'Increment',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
