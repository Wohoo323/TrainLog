import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../ui/workout_ui.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  final Workout workout;

  const WorkoutDetailsScreen({super.key, required this.workout});

  String _dateText(DateTime d) => '${d.day}.${d.month}.${d.year}';

  String _pacePer100Text(double paceMinPer100) {
    final min = paceMinPer100.floor();
    final sec = ((paceMinPer100 - min) * 60).round().clamp(0, 59);
    final sec2 = sec.toString().padLeft(2, '0');
    return '$min:$sec2 / 100m';
  }

  @override
  Widget build(BuildContext context) {
    final accent = WorkoutUI.color(workout.type);

    return Scaffold(
      appBar: AppBar(
        title: Text('${WorkoutUI.label(workout.type)} details'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        children: [
          // Header card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(WorkoutUI.icon(workout.type), color: accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${WorkoutUI.label(workout.type)} • ${workout.durationMinutes} min',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _dateText(workout.date),
                          style: TextStyle(color: Colors.white.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    workout.caloriesBurned == null
                        ? 'kcal —'
                        : 'kcal ${workout.caloriesBurned!.round()}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // TYPE-SPECIFIC DETAILS
          ..._buildTypeDetails(context),
        ],
      ),
    );
  }

  List<Widget> _buildTypeDetails(BuildContext context) {
    final d = workout.details;

    // SWIM
    if (workout.type == WorkoutType.swim && d is SwimDetails) {
      return [
        _infoCard(
          title: 'Swim details',
          rows: [
            ('Distance', '${d.distanceMeters} m'),
            ('Time', '${d.timeMinutes} min'),
            ('Pool', d.poolMeters == 0 ? 'Open water' : '${d.poolMeters} m'),
            ('Stroke', d.stroke),
            ('Pace', _pacePer100Text(d.pacePer100)),
          ],
        ),
      ];
    }

    // GYM
    if (workout.type == WorkoutType.gym && d is GymDetails) {
      return [
        _infoCard(
          title: d.sessionName,
          rows: [
            ('Exercises', '${d.exerciseCount}'),
            ('Total volume', '${d.totalVolume.round()} kg'),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Exercises',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        ...d.exercises.map((e) {
          return Card(
            child: ListTile(
              title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text(
                '${e.sets} x ${e.reps} @ ${e.weightKg.toStringAsFixed(1)} kg',
                style: TextStyle(color: Colors.white.withOpacity(0.75)),
              ),
              trailing: Text(
                '${e.volume.round()} kg',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          );
        }).toList(),
      ];
    }

    // FALLBACK
    return [
      _infoCard(
        title: 'Details',
        rows: const [
          ('Info', 'No details available for this workout yet'),
        ],
      ),
    ];
  }

  Widget _infoCard({
    required String title,
    required List<(String, String)> rows,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            ...rows.map((r) {
              final label = r.$1;
              final value = r.$2;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7))),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        value,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
