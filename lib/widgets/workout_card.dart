import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../ui/workout_ui.dart';

class WorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback onToggleCompleted;

  // 🔹 UUSI: kortin painallus (avaa details)
  final VoidCallback? onTap;

  const WorkoutCard({
    super.key,
    required this.workout,
    required this.onToggleCompleted,
    this.onTap,
  });

  // --- Apurit formatoimiseen ---

  String _dateText(DateTime d) => '${d.day}.${d.month}.${d.year}';

  String _kcalText(double? kcal) =>
      kcal == null ? 'kcal: —' : 'kcal: ${kcal.round()}';

  /// Format pace: min per 100m -> "2:30 / 100m"
  String _pacePer100Text(double paceMinPer100) {
    final min = paceMinPer100.floor();
    final sec = ((paceMinPer100 - min) * 60).round().clamp(0, 59);
    final sec2 = sec.toString().padLeft(2, '0');
    return '$min:$sec2 / 100m';
  }

  @override
  Widget build(BuildContext context) {
    final accent = WorkoutUI.color(workout.type);

    // ---- Type-kohtainen “extra info” ----
    String? extraLine1;
    String? extraLine2;

    final details = workout.details;

    if (workout.type == WorkoutType.swim && details is SwimDetails) {
      extraLine1 = '${details.distanceMeters} m • ${details.stroke}';
      extraLine2 = 'pace ${_pacePer100Text(details.pacePer100)}';
    } else if (workout.type == WorkoutType.run && details is RunDetails) {
      extraLine1 = '${details.distanceKm.toStringAsFixed(2)} km';
      extraLine2 = 'pace ${details.pacePerKm.toStringAsFixed(2)} min/km';
    } else if (workout.type == WorkoutType.bike && details is BikeDetails) {
      extraLine1 = '${details.distanceKm.toStringAsFixed(1)} km';
      extraLine2 = 'avg ${details.avgSpeedKmh.toStringAsFixed(1)} km/h';
    } else if (workout.type == WorkoutType.gym && details is GymDetails) {
      extraLine1 =
      '${details.sessionName} • ${details.exerciseCount} exercises';
      extraLine2 = 'volume ${details.totalVolume.round()} kg';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      // 🔹 UUSI: InkWell koko kortin ympärille
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,

        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Ikoni-badge
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    WorkoutUI.icon(workout.type),
                    color: accent,
                  ),
                ),
                const SizedBox(width: 12),

                // Tekstit
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Otsikko
                      Text(
                        '${WorkoutUI.label(workout.type)} • ${workout.durationMinutes} min',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      if (extraLine1 != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          extraLine1!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      if (extraLine2 != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          extraLine2!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Chipit
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          _MiniChip(
                            icon: Icons.calendar_month_rounded,
                            text: _dateText(workout.date),
                          ),
                          _MiniChip(
                            icon: Icons.local_fire_department_rounded,
                            text: _kcalText(workout.caloriesBurned),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Completed nappi (oma InkWell → ei avaa details)
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: onToggleCompleted,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: workout.completed
                          ? accent.withOpacity(0.18)
                          : Colors.white.withOpacity(0.06),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      workout.completed
                          ? Icons.check_rounded
                          : Icons.circle_outlined,
                      color: workout.completed
                          ? accent
                          : Colors.white.withOpacity(0.55),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white.withOpacity(0.7)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

