import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dart:io';

import '../washing_machine.dart';

Future<String?> getLocalIp() async {
  for (var interface in await NetworkInterface.list()) {
    for (var addr in interface.addresses) {
      if (addr.type == InternetAddressType.IPv4 &&
          !addr.address.startsWith('127.')) {
        return addr.address;
      }
    }
  }
  return null;
}

Future<bool> checkIPisWashingMachine(String ip) async {
  String url =
      'http://$ip/current_status'; // Modify with actual API endpoint if needed

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Response Data: ${response.body}');
      print("IP Found $ip");
      return true;
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
  return false;
}

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});
  @override
  State<ScannerScreen> createState() => ScannerScreenState();
}

class ScannerScreenState extends State<ScannerScreen> {
  TextEditingController hostnameController =
      TextEditingController(text: "192.168.22.101");

  final List<Host> _hosts = <Host>[];

  double? progress = 0.0;

  void returnToHome() {
    setState(() {
      WashingMachine.instance.hostname = hostnameController.text;
    });

    WashingMachine.instance.saveSettings();
    Navigator.pop(context, WashingMachine.instance.hostname);
  }

  void loadSettings() async {
    WashingMachine.instance.loadSettings();
    setState(() {
      hostnameController.text = WashingMachine.instance.hostname;
    });
  }

  void scanIP() async {
 setState(() {
                      progress = 0.0;
                      _hosts.clear();
                    });

                    // String? localIp = await getLocalIp();
                    // await NetworkInfo().getWifiIP()

                    final scanner = LanScanner(debugLogging: true);
                    final stream = scanner.icmpScan(
                      ipToCSubnet(await getLocalIp() ?? '192.168.127.101'),
                      scanThreads: 20,
                      progressCallback: (newProgress) {
                        setState(() {
                          progress = newProgress;
                        });
                      },
                    );

                    stream.listen((Host host) {
                      setState(() async {
                        _hosts.add(host);
                        String ipaddress = host.internetAddress.address;
                        bool isWashingMachine =
                            await checkIPisWashingMachine(ipaddress);

                        print(
                            "is washing machine $isWashingMachine $ipaddress");

                        if (isWashingMachine) {
                          print('ip set $ipaddress');

                          setState(() {
                            hostnameController.text = ipaddress;
                          });
                        }
                      });
                    });
  }

  @override
  void initState() {
    super.initState();
    debugPrint('ScannerScreen');
    loadSettings();
    scanIP();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner'),
      ),
      body: Container(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(labelText: "Hostname"),
              controller: hostnameController,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: returnToHome,
                  child: const Text('Connect'),
                ),
                FilledButton(
                  onPressed: scanIP,
                  child: const Text('Scan'),
                ),
              ],
            ),
             const SizedBox(height: 8),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _hosts.length,
                itemBuilder: (context, index) {
                  final host = _hosts[index];
                  final address = host.internetAddress.address;
                  final time = host.pingTime;

                  // print(host);
                     print(address);
              
                  


                  return Card(
                    child: ListTile(
                      title: Text(address),
                      trailing: Text(time != null ? time.toString() : 'N/A'),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
