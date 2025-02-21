import 'package:flutter/material.dart';

import 'washing_machine/washing_machine_screen.dart';

import 'package:flutter/foundation.dart';
// import 'package:wakelock/wakelock.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (defaultTargetPlatform == TargetPlatform.android) {
// YOUR CODE
    // Wakelock.enable();
  }

  runApp(const WashingMachineApp());
}

class WashingMachineApp extends StatelessWidget {
  const WashingMachineApp({super.key});

  // @override
  // void dispose() {
  //   Wakelock.disable();
  // super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Washing Machine App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WashingMachineScreen(),
      },
    );
  }
}
