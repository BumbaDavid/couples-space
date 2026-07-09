import 'package:flutter/material.dart';

import '../../features/private_notes/ui/private_notes_screen.dart';
import '../../features/profile/ui/profile_screen.dart';
import '../../features/shared_notes/ui/shared_notes_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  static const _tabs = <Widget>[
    SharedNotesScreen(),
    PrivateNotesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.people), label: 'Shared'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Private'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Profile'),
        ],
      ),
    );
  }
}
