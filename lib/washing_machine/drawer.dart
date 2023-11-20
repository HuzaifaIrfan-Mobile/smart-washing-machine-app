import 'package:flutter/material.dart';

class NavDrawer extends StatelessWidget {
  Function()? restartMachine;
  Function(int, int)? setNextTask;

  NavDrawer({
    super.key,
    required this.restartMachine,
    required this.setNextTask,
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
              'Tasks Menu',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.water_drop),
            title: const Text('Filling'),
            onTap: () => {setNextTask!(1, 600)},
          ),
          ListTile(
            leading: const Icon(Icons.wash),
            title: const Text('Washing'),
            onTap: () => {setNextTask!(2, 300)},
          ),
          ListTile(
            leading: const Icon(Icons.pause),
            title: const Text('Soaking'),
            onTap: () => {setNextTask!(3, 300)},
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Draining'),
            onTap: () => {setNextTask!(4, 300)},
          ),
          ListTile(
            leading: const Icon(Icons.dry),
            title: const Text('Drying'),
            onTap: () => {setNextTask!(5, 120)},
          ),
          const Divider(),
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
