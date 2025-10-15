import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _flashlight = false;
  String _selectedCamera = 'Back Camera';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.background,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Camera Selection'),
            subtitle: const Text('Choose between front and back camera'),
            trailing: DropdownButton<String>(
              value: _selectedCamera,
              items: const <String>['Back Camera', 'Front Camera']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCamera = newValue!;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('Flashlight'),
            subtitle: const Text('Enable/disable flashlight'),
            trailing: Switch(
              value: _flashlight,
              onChanged: (value) {
                setState(() {
                  _flashlight = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Enable/disable notifications'),
            trailing: Switch(
              value: _notifications,
              onChanged: (value) {
                setState(() {
                  _notifications = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable/disable dark mode'),
            trailing: Switch(
              value: _darkMode,
              onChanged: (value) {
                setState(() {
                  _darkMode = value;
                });
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Firebase Test'),
            subtitle: const Text('Test Firebase connection'),
            trailing: const Icon(Icons.cloud),
            onTap: () {
              Navigator.pushNamed(context, '/firebase-test');
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('About'),
            trailing: Text('Version 1.0.0'),
          ),
        ],
      ),
    );
  }
} 