import 'package:flutter/material.dart';
import 'settings/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WashingMachineScreen extends StatefulWidget {
  const WashingMachineScreen({super.key});
  @override
  State<WashingMachineScreen> createState() => WashingMachineScreenState();
}

class WashingMachineScreenState extends State<WashingMachineScreen> {
  WashingMachineScreenState() {}

  var hostname = "192.168.10.225";

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Washing Machine'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: openSettingsScreen,
          child: const Text('Settings'),
        ),
      ),
    );
  }
}
