import 'package:flutter/material.dart';

abstract class WorkoutIcons {
  static const List<String> bodyParts = [
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Arms',
    'Core',
    'Endurance',
  ];

  static bool isEndurance(String bodyPart) =>
      bodyPart == 'Endurance' || bodyPart == 'Cardio';

  static IconData forBodyPart(String bodyPart) => switch (bodyPart) {
        'Chest' => Icons.fitness_center,
        'Back' => Icons.rowing,
        'Legs' => Icons.directions_run,
        'Shoulders' => Icons.sports_gymnastics,
        'Arms' => Icons.sports_handball,
        'Core' => Icons.self_improvement,
        'Endurance' => Icons.timer,
        _ => Icons.fitness_center,
      };
}
