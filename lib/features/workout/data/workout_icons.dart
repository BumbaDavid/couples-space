import 'package:flutter/material.dart';

abstract class WorkoutIcons {
  static const List<String> bodyParts = [
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Arms',
    'Core',
    'Cardio',
  ];

  static IconData forBodyPart(String bodyPart) => switch (bodyPart) {
        'Chest' => Icons.fitness_center,
        'Back' => Icons.rowing,
        'Legs' => Icons.directions_run,
        'Shoulders' => Icons.sports_gymnastics,
        'Arms' => Icons.sports_handball,
        'Core' => Icons.self_improvement,
        'Cardio' => Icons.directions_bike,
        _ => Icons.fitness_center,
      };
}
