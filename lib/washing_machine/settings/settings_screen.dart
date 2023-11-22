import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  var hostname = "192.168.10.225";

  TextEditingController hostnameController =
      TextEditingController(text: "hostname");

  // SettingsScreenState() {}

  void loadHostname() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      hostname = (prefs.getString('hostname') ?? "192.168.10.225");
      hostnameController.text = hostname;
    });
    debugPrint("Loaded Hostname: $hostname");
  }

  void saveHostname() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      hostname = hostnameController.text;
      prefs.setString('hostname', hostname);
    });
    debugPrint("Saved Hostname: $hostname");
  }

  void returnHostname() {
    Navigator.pop(context, hostname);
  }

  @override
  void initState() {
    super.initState();
    loadHostname();
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: saveHostname,
              child: const Text('Save Hostname'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: restartMachine,
              child: const Text('Restart Machine'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: returnHostname,
              child: const Text('Go back!'),
            ),
          ],
        ),
      ),
    );
  }
}
