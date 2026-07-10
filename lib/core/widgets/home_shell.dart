import 'package:flutter/material.dart';

import '../../features/private_notes/ui/private_notes_screen.dart';
import '../../features/profile/ui/profile_screen.dart';
import '../../features/shared_notes/ui/shared_notes_screen.dart';
import '../../features/workout/ui/exercise_list_screen.dart';
import '../../features/workout/ui/progress_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _mainIndex = 0; // 0=Shared 1=Private 2=Workouts 3=Profile
  int _workoutTab = 0; // 0=Exercises 1=Progress (only used when _mainIndex==2)

  Widget _body() => switch (_mainIndex) {
        0 => const SharedNotesScreen(),
        1 => const PrivateNotesScreen(),
        2 => _workoutTab == 0
            ? const ExerciseListScreen()
            : const ProgressScreen(),
        3 => const ProfileScreen(),
        _ => const SharedNotesScreen(),
      };

  NavigationBar _navBar() {
    if (_mainIndex == 2) {
      return NavigationBar(
        selectedIndex: _workoutTab,
        onDestinationSelected: (i) {
          if (i == 2) {
            setState(() {
              _mainIndex = 0;
              _workoutTab = 0;
            });
          } else {
            setState(() => _workoutTab = i);
          }
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.fitness_center), label: 'Exercises'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart), label: 'Progress'),
          NavigationDestination(
              icon: Icon(Icons.home_outlined), label: 'Home'),
        ],
      );
    }
    return NavigationBar(
      selectedIndex: _mainIndex,
      onDestinationSelected: (i) => setState(() => _mainIndex = i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.people), label: 'Shared'),
        NavigationDestination(icon: Icon(Icons.person), label: 'Private'),
        NavigationDestination(
            icon: Icon(Icons.fitness_center), label: 'Workouts'),
        NavigationDestination(icon: Icon(Icons.settings), label: 'Profile'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _mainIndex != 2,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _mainIndex == 2) {
          setState(() {
            _mainIndex = 0;
            _workoutTab = 0;
          });
        }
      },
      child: Scaffold(
        body: _body(),
        bottomNavigationBar: _navBar(),
      ),
    );
  }
}
