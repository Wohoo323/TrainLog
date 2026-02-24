import 'package:flutter/material.dart';
import '../models/workout.dart';

class WorkoutUI {
  static String label(WorkoutType t) => switch (t) {
    WorkoutType.gym => 'Gym',
    WorkoutType.swim => 'Swim',
    WorkoutType.run => 'Run',
    WorkoutType.bike => 'Bike',
  };

  static IconData icon(WorkoutType t) => switch (t) {
    WorkoutType.gym => Icons.fitness_center_rounded,
    WorkoutType.swim => Icons.pool_rounded,
    WorkoutType.run => Icons.directions_run_rounded,
    WorkoutType.bike => Icons.directions_bike_rounded,
  };

  static Color color(WorkoutType t) => switch (t) {
    WorkoutType.gym => const Color(0xFF7C3AED), // violet
    WorkoutType.swim => const Color(0xFF06B6D4), // cyan
    WorkoutType.run => const Color(0xFFF97316), // orange
    WorkoutType.bike => const Color(0xFF22C55E), // green
  };
}
