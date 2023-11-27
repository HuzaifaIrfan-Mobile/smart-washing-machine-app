import 'package:flutter/material.dart';
import 'settings/settings_screen.dart';
import 'dart:async';

import 'package:percent_indicator/circular_percent_indicator.dart';

import 'washing_machine.dart';

class WashingMachineScreen extends StatefulWidget {
  const WashingMachineScreen({super.key});
  @override
  State<WashingMachineScreen> createState() => WashingMachineScreenState();
}

class WashingMachineScreenState extends State<WashingMachineScreen> {
  Timer? timer;

  WashingMachineScreenState() {
    setupRefreshCurrentStatusTimer();
  }

  void setupRefreshCurrentStatusTimer() {
    Duration period = const Duration(seconds: 1);
    timer = Timer.periodic(period, (arg) {
      WashingMachine.instance.refreshCurrentStatus();
      setState(() {});
    });
  }

  void cancelRefreshCurrentStatusTimer() {
    timer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    WashingMachine.instance.loadSettings();
    // debugPrint('WashingMachineScreen');
  }

  void openSettingsScreen() async {
    WashingMachine.instance.pauseMachine();
    cancelRefreshCurrentStatusTimer();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
    if (result != null) {
      debugPrint("Returned Hostname: $result");
    }
    WashingMachine.instance.loadSettings();
    setupRefreshCurrentStatusTimer();
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
                  WashingMachine.instance.message,
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
                        WashingMachine.instance.centerLabel,
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
                          onPressed: WashingMachine.instance.runMachine,
                          tooltip: 'Run',
                          child: const Icon(Icons.play_arrow),
                        ),
                        FloatingActionButton(
                          heroTag: "pauseMachine",
                          onPressed: WashingMachine.instance.pauseMachine,
                          tooltip: 'Pause',
                          child: const Icon(Icons.stop),
                        ),
                        FloatingActionButton(
                          heroTag: "holdMachine",
                          onPressed: WashingMachine.instance.holdMachine,
                          tooltip: 'Hold',
                          child: const Icon(Icons.pause),
                        ),
                        FloatingActionButton(
                          heroTag: "skipMachine",
                          onPressed: WashingMachine.instance.skipMachine,
                          tooltip: 'Skip',
                          child: const Icon(Icons.skip_next),
                        ),
                        FloatingActionButton(
                          heroTag: "resetMachine",
                          onPressed: WashingMachine.instance.resetMachine,
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
                                  WashingMachine.instance.setNextTask(
                                      1,
                                      int.parse(WashingMachine
                                          .instance.fillingTaskCountdown))
                                },
                            text: "Fill",
                            icon: "filling.png"),
                        imageIconButtons(
                            onPressed: () => {
                                  WashingMachine.instance.setNextTask(
                                      2,
                                      int.parse(WashingMachine
                                          .instance.washingTaskCountdown))
                                },
                            text: "Wash",
                            icon: "washing.png"),
                        imageIconButtons(
                            onPressed: () => {
                                  WashingMachine.instance.setNextTask(
                                      3,
                                      int.parse(WashingMachine
                                          .instance.soakingTaskCountdown))
                                },
                            text: "Soak",
                            icon: "soaking.png"),
                        imageIconButtons(
                            onPressed: () => {
                                  WashingMachine.instance.setNextTask(
                                      4,
                                      int.parse(WashingMachine
                                          .instance.drainingTaskCountdown))
                                },
                            text: "Drain",
                            icon: "draining.png"),
                        imageIconButtons(
                            onPressed: () => {
                                  WashingMachine.instance.setNextTask(
                                      5,
                                      int.parse(WashingMachine
                                          .instance.dryingTaskCountdown))
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
    heroTag: "hero$text",
    onPressed: onPressed,
    tooltip: text,
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
