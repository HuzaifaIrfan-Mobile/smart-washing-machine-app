import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'defaults.dart';

import '../washing_machine.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  TextEditingController hostnameController =
      TextEditingController(text: defaultHostname);
        TextEditingController octetController =
      TextEditingController(text: defaultOctet);


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
    WashingMachine.instance.loadSettings();
    setState(() {
      hostnameController.text = WashingMachine.instance.hostname;
            octetController.text = WashingMachine.instance.octet;


      fillingTaskCountdownController.text =
          WashingMachine.instance.fillingTaskCountdown;
      washingTaskCountdownController.text =
          WashingMachine.instance.washingTaskCountdown;
      soakingTaskCountdownController.text =
          WashingMachine.instance.soakingTaskCountdown;
      drainingTaskCountdownController.text =
          WashingMachine.instance.drainingTaskCountdown;
      dryingTaskCountdownController.text =
          WashingMachine.instance.dryingTaskCountdown;
    });
  }

  void saveSettings() async {
    setState(() {
      WashingMachine.instance.hostname = hostnameController.text;
            WashingMachine.instance.octet = octetController.text;

      WashingMachine.instance.fillingTaskCountdown =
          fillingTaskCountdownController.text;
      WashingMachine.instance.washingTaskCountdown =
          washingTaskCountdownController.text;
      WashingMachine.instance.soakingTaskCountdown =
          soakingTaskCountdownController.text;
      WashingMachine.instance.drainingTaskCountdown =
          drainingTaskCountdownController.text;
      WashingMachine.instance.dryingTaskCountdown =
          dryingTaskCountdownController.text;
    });

    WashingMachine.instance.saveSettings();

    loadSettings();
  }

  void returnToHome() {
    saveSettings();
    Navigator.pop(context, WashingMachine.instance.hostname);
  }

  @override
  void initState() {
    super.initState();
    loadSettings();
    debugPrint('SettingsScreen');
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
              decoration: const InputDecoration(labelText: "Octet"),
              controller: octetController,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    WashingMachine.instance.restartMachine();
                  },
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
