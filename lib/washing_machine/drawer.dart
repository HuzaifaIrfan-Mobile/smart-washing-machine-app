import 'package:flutter/material.dart';

class NavDrawer extends StatelessWidget {
  Function()? restartMachine;

  NavDrawer({
    super.key,
    required this.restartMachine,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
              // image: DecorationImage(
              //     fit: BoxFit.fill,
              //     image: AssetImage('assets/images/cover.jpg'),
            ),
            child: Text(
              'Side menu',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Restart'),
            onTap: restartMachine,
          ),
        ],
      ),
    );
  }
}
