import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'defaults.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  var hostname = defaultHostname;
  var fillingTaskCountdown = defaultFillingTaskCountdown;
  var washingTaskCountdown = defaultWashingTaskCountdown;
  var soakingTaskCountdown = defaultSoakingTaskCountdown;
  var drainingTaskCountdown = defaultDrainingTaskCountdown;
  var dryingTaskCountdown = defaultDryingTaskCountdown;

  TextEditingController hostnameController =
      TextEditingController(text: defaultHostname);

  TextEditingController fillingTaskCountdownController =
      TextEditingController(text: defaultFillingTaskCountdown);
  TextEditingController washingTaskCountdownController =
      TextEditingController(text: defaultWashingTaskCountdown);
  TextEditingController soakingTaskCountdownController =
      TextEditingController(text: defaultSoakingTaskCountdown);
  TextEditingController drainingTaskCountdownController =
      TextEditingController(text: defaultDrainingTaskCountdown);
  TextEditingController dryingTaskCountdownController =
      TextEditingController(text: defaultDryingTaskCountdown);

  // SettingsScreenState() {}

  void loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      hostname = (prefs.getString('hostname') ?? defaultHostname);
      hostnameController.text = hostname;

      fillingTaskCountdown = (prefs.getString('fillingTaskCountdown') ??
          defaultFillingTaskCountdown);
      fillingTaskCountdownController.text = fillingTaskCountdown;
      washingTaskCountdown = (prefs.getString('washingTaskCountdown') ??
          defaultWashingTaskCountdown);
      washingTaskCountdownController.text = washingTaskCountdown;
      soakingTaskCountdown = (prefs.getString('soakingTaskCountdown') ??
          defaultSoakingTaskCountdown);
      soakingTaskCountdownController.text = soakingTaskCountdown;
      drainingTaskCountdown = (prefs.getString('drainingTaskCountdown') ??
          defaultDrainingTaskCountdown);
      drainingTaskCountdownController.text = drainingTaskCountdown;
      dryingTaskCountdown = (prefs.getString('dryingTaskCountdown') ??
          defaultDryingTaskCountdown);
      dryingTaskCountdownController.text = dryingTaskCountdown;
    });
    debugPrint("Loaded hostname: $hostname");

    debugPrint("Loaded fillingTaskCountdown: $fillingTaskCountdown");
    debugPrint("Loaded washingTaskCountdown: $washingTaskCountdown");
    debugPrint("Loaded soakingTaskCountdown: $soakingTaskCountdown");
    debugPrint("Loaded drainingTaskCountdown: $drainingTaskCountdown");
    debugPrint("Loaded dryingTaskCountdown: $dryingTaskCountdown");
  }

  void saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      hostname = hostnameController.text;
      prefs.setString('hostname', hostname);

      fillingTaskCountdown = fillingTaskCountdownController.text;
      prefs.setString('fillingTaskCountdown', fillingTaskCountdown);
      washingTaskCountdown = washingTaskCountdownController.text;
      prefs.setString('washingTaskCountdown', washingTaskCountdown);
      soakingTaskCountdown = soakingTaskCountdownController.text;
      prefs.setString('soakingTaskCountdown', soakingTaskCountdown);
      drainingTaskCountdown = drainingTaskCountdownController.text;
      prefs.setString('drainingTaskCountdown', drainingTaskCountdown);
      dryingTaskCountdown = dryingTaskCountdownController.text;
      prefs.setString('dryingTaskCountdown', dryingTaskCountdown);
    });

    debugPrint("Saved hostname: $hostname");

    debugPrint("Saved fillingTaskCountdown: $fillingTaskCountdown");
    debugPrint("Saved washingTaskCountdown: $washingTaskCountdown");
    debugPrint("Saved soakingTaskCountdown: $soakingTaskCountdown");
    debugPrint("Saved drainingTaskCountdown: $drainingTaskCountdown");
    debugPrint("Saved dryingTaskCountdown: $dryingTaskCountdown");

    loadSettings();
  }

  void returnToHome() {
    Navigator.pop(context, hostname);
  }

  @override
  void initState() {
    super.initState();
    loadSettings();
    debugPrint('SettingsScreen');
  }

  void restartMachine() async {
    debugPrint("Restart Machine");
    var url = Uri.http(hostname, '/restart');
    try {
      await http.get(url);
    } catch (e) {
      debugPrint('$e');
    }
    debugPrint("Restarted Machine");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Container(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(labelText: "Hostname"),
              controller: hostnameController,
            ),
            TextField(
              decoration:
                  const InputDecoration(labelText: "Filling Task Countdown"),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ], // Only numbers can be entered
              controller: fillingTaskCountdownController,
            ),
            TextField(
              decoration:
                  const InputDecoration(labelText: "Washing Task Countdown"),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ], // Only numbers can be entered
              controller: washingTaskCountdownController,
            ),
            TextField(
              decoration:
                  const InputDecoration(labelText: "Soaking Task Countdown"),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ], // Only numbers can be entered
              controller: soakingTaskCountdownController,
            ),
            TextField(
              decoration:
                  const InputDecoration(labelText: "Draining Task Countdown"),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ], // Only numbers can be entered
              controller: drainingTaskCountdownController,
            ),
            TextField(
              decoration:
                  const InputDecoration(labelText: "Drying Task Countdown"),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ], // Only numbers can be entered
              controller: dryingTaskCountdownController,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: saveSettings,
              child: const Text('Save Settings'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: restartMachine,
                  child: const Text('Restart Machine'),
                ),
                ElevatedButton(
                  onPressed: returnToHome,
                  child: const Text('Go back!'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             TextField(
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 hintText: 'hostname',
//               ),
//               controller: hostnameController,
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: saveSettings,
//               child: const Text('Save Settings'),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: restartMachine,
//               child: const Text('Restart Machine'),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: returnToHome,
//               child: const Text('Go back!'),
//             ),
//           ],
//         ),
//       ),
