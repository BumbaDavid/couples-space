import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/private_notes/ui/private_notes_screen.dart';
import '../../features/profile/ui/profile_screen.dart';
import '../../features/protein/ui/protein_progress_screen.dart';
import '../../features/protein/ui/protein_screen.dart';
import '../../features/protein/ui/widgets/protein_common.dart';
import '../../features/reminders/ui/reminders_list_screen.dart';
import '../../features/shared_notes/ui/shared_notes_screen.dart';
import '../../features/workout/ui/exercise_list_screen.dart';
import '../../features/workout/ui/progress_screen.dart';
import '../theme/theme.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  // 0=Shared 1=Private 2=Workouts 3=Reminders 4=Protein 5=Profile
  // Profile stays last: new feature tabs are inserted before it, never after.
  int _mainIndex = 0;
  int _workoutTab = 0; // 0=Exercises 1=Progress (only used when _mainIndex==2)
  int _proteinTab = 0; // 0=Protein 1=Progress (only used when _mainIndex==4)

  static const _tabs = [
    _NavTab(icon: Icons.people, label: 'Shared'),
    _NavTab(icon: Icons.person, label: 'Private'),
    _NavTab(icon: Icons.fitness_center, label: 'Workouts'),
    _NavTab(icon: Icons.notifications, label: 'Reminders'),
    // The design names Material Symbols `nutrition`, which has no Flutter
    // `Icons` equivalent — see protein_icons.dart.
    _NavTab(icon: Icons.restaurant_menu, label: 'Protein'),
    _NavTab(icon: Icons.settings, label: 'Profile'),
  ];

  Widget _body() => switch (_mainIndex) {
        0 => const SharedNotesScreen(),
        1 => const PrivateNotesScreen(),
        2 => _workoutTab == 0
            ? const ExerciseListScreen()
            : const ProgressScreen(),
        3 => const RemindersListScreen(),
        4 => _proteinBody(),
        5 => const ProfileScreen(),
        _ => const SharedNotesScreen(),
      };

  /// Unlike Workouts, the Protein tab keeps the scrollable bottom nav visible
  /// and puts its own two-segment switcher inside the screen — so it needs no
  /// "Home" segment to escape back to the other tabs.
  Widget _proteinBody() => SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: PillSwitcher(
                labels: const ['Protein', 'Progress'],
                selectedIndex: _proteinTab,
                onSelected: (i) => setState(() => _proteinTab = i),
              ),
            ),
            Expanded(
              child: _proteinTab == 0
                  ? const ProteinScreen()
                  : const ProteinProgressScreen(),
            ),
          ],
        ),
      );

  Widget _navBar() {
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
    return _ScrollableNavBar(
      selectedIndex: _mainIndex,
      tabs: _tabs,
      onDestinationSelected: (i) => setState(() => _mainIndex = i),
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

class _NavTab {
  const _NavTab({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

/// Horizontally scrollable bottom nav — main tab count will keep growing, so
/// unlike a fixed `NavigationBar` this doesn't need to shrink items to fit.
class _ScrollableNavBar extends StatelessWidget {
  const _ScrollableNavBar({
    required this.selectedIndex,
    required this.tabs,
    required this.onDestinationSelected,
  });
  final int selectedIndex;
  final List<_NavTab> tabs;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < tabs.length; i++)
                _NavItem(
                  tab: tabs[i],
                  selected: i == selectedIndex,
                  onTap: () => onDestinationSelected(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });
  final _NavTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.muted;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 84,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tab.icon, size: 25, color: color),
            const SizedBox(height: 2),
            Text(
              tab.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
