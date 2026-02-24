import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/workout.dart';
import '../ui/workout_ui.dart';
import 'workout_details_screen.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  DateTime _startOfWeek(DateTime now) {
    final diff = now.weekday - DateTime.monday; // Mon=1
    return DateTime(now.year, now.month, now.day).subtract(Duration(days: diff));
  }

  String _typeLabel(WorkoutType t) => switch (t) {
    WorkoutType.gym => 'Gym',
    WorkoutType.swim => 'Swim',
    WorkoutType.run => 'Run',
    WorkoutType.bike => 'Bike',
  };

  String _weekdayLabel(int weekday) => switch (weekday) {
    1 => 'Mon',
    2 => 'Tue',
    3 => 'Wed',
    4 => 'Thu',
    5 => 'Fri',
    6 => 'Sat',
    _ => 'Sun',
  };

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Workout>('workouts');

    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Workout> box, _) {
          final all = box.values.toList();

          final now = DateTime.now();
          final weekStart = _startOfWeek(now);
          final weekEnd = weekStart.add(const Duration(days: 7));

          final thisWeek = all.where((w) {
            final d = w.date;
            return (d.isAtSameMomentAs(weekStart) || d.isAfter(weekStart)) &&
                d.isBefore(weekEnd);
          }).toList();

          // Counts
          const goal = 5;
          final totalCount = thisWeek.length;
          final progress = (totalCount / goal).clamp(0.0, 1.0);

          final completed = thisWeek.where((w) => w.completed).toList();
          final completedCount = completed.length;

          // Calories
          final totalKcal = completed.fold<double>(
            0.0,
                (sum, w) => sum + (w.caloriesBurned ?? 0.0),
          );
          final avgKcal = completed.isEmpty ? 0.0 : (totalKcal / completed.length);

          // By type (completed)
          final Map<WorkoutType, int> byType = {
            WorkoutType.gym: 0,
            WorkoutType.swim: 0,
            WorkoutType.run: 0,
            WorkoutType.bike: 0,
          };
          for (final w in completed) {
            byType[w.type] = (byType[w.type] ?? 0) + 1;
          }

          WorkoutType? topType;
          int topCount = 0;
          byType.forEach((t, c) {
            if (c > topCount) {
              topCount = c;
              topType = t;
            }
          });

          // Latest workout
          Workout? latest;
          if (all.isNotEmpty) {
            all.sort((a, b) => b.date.compareTo(a.date));
            latest = all.first;
          }

          // Best day (this week, by count)
          final Map<int, int> perWeekday = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
          for (final w in thisWeek) {
            perWeekday[w.date.weekday] = (perWeekday[w.date.weekday] ?? 0) + 1;
          }
          int bestDay = 1;
          int bestDayCount = 0;
          perWeekday.forEach((day, c) {
            if (c > bestDayCount) {
              bestDayCount = c;
              bestDay = day;
            }
          });

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              // HEADER
              Text(
                'This week',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),

              // BIG WEEK CARD
              _CardSurface(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ProgressRing(
                        progress: progress,
                        mainText: '$totalCount/$goal',
                        subText: 'workouts',
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Weekly progress',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              totalCount >= goal
                                  ? 'Goal reached 🔥'
                                  : 'Keep going — ${goal - totalCount} to reach goal',
                              style: TextStyle(
                                color: Colors.white.withAlpha(190),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 8,
                              children: [
                                _MiniChip(
                                  icon: Icons.check_circle_outline_rounded,
                                  text: '$completedCount completed',
                                ),
                                _MiniChip(
                                  icon: Icons.local_fire_department_rounded,
                                  text: totalKcal > 0 ? '${totalKcal.round()} kcal' : 'kcal: —',
                                ),
                                _MiniChip(
                                  icon: Icons.emoji_events_rounded,
                                  text: bestDayCount > 0
                                      ? 'Best: ${_weekdayLabel(bestDay)} ($bestDayCount)'
                                      : 'Best: —',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // SMALL STATS GRID
              Row(
                children: [
                  Expanded(
                    child: _GradientCard(
                      title: 'Calories',
                      subtitle: 'Completed only',
                      gradientA: const Color(0xFF0F172A),
                      gradientB: const Color(0xFF111827),
                      trailing: const Icon(Icons.local_fire_department_rounded),
                      child: Text(
                        totalKcal > 0 ? '${totalKcal.round()}' : '—',
                        style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GradientCard(
                      title: 'Avg kcal',
                      subtitle: 'Per completed',
                      gradientA: const Color(0xFF1E1B4B),
                      gradientB: const Color(0xFF0B0F1A),
                      trailing: const Icon(Icons.analytics_rounded),
                      child: Text(
                        completed.isEmpty ? '—' : '${avgKcal.round()}',
                        style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // BY TYPE
              _CardSurface(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'By type (completed)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 12),

                      ...WorkoutType.values.map((t) {
                        final c = byType[t] ?? 0;
                        final denom = completedCount == 0 ? 1 : completedCount;
                        final p = (c / denom).clamp(0.0, 1.0);
                        final accent = WorkoutUI.color(t);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: accent.withAlpha(40),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(WorkoutUI.icon(t), color: accent, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _typeLabel(t),
                                            style: const TextStyle(fontWeight: FontWeight.w800),
                                          ),
                                        ),
                                        Text(
                                          '$c',
                                          style: TextStyle(
                                            color: Colors.white.withAlpha(190),
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(999),
                                      child: LinearProgressIndicator(
                                        value: p,
                                        minHeight: 8,
                                        backgroundColor: Colors.white.withAlpha(20),
                                        valueColor: AlwaysStoppedAnimation(accent),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 4),
                      Text(
                        topType == null
                            ? 'Most common: —'
                            : 'Most common: ${_typeLabel(topType!)} ($topCount)',
                        style: TextStyle(
                          color: Colors.white.withAlpha(180),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // LATEST WORKOUT
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: latest == null
                    ? null
                    : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WorkoutDetailsScreen(workout: latest!),
                    ),
                  );
                },
                child: _CardSurface(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(18),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.history_rounded),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Latest workout',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                latest == null
                                    ? 'No workouts yet'
                                    : '${latest.type.name.toUpperCase()} • ${latest.durationMinutes} min',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(190),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                latest == null
                                    ? ''
                                    : (latest.caloriesBurned == null
                                    ? 'kcal: —'
                                    : 'kcal: ${latest.caloriesBurned!.round()}'),
                                style: TextStyle(
                                  color: Colors.white.withAlpha(150),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (latest != null) const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

//
// ─────────────────────────────
// PROGRESS RING (FIXED)
// ─────────────────────────────
//

class ProgressRing extends StatelessWidget {
  final double progress;
  final String mainText;
  final String subText;

  const ProgressRing({
    super.key,
    required this.progress,
    required this.mainText,
    required this.subText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 10,
            backgroundColor: Colors.white.withAlpha(20),
            valueColor: AlwaysStoppedAnimation(
              Colors.redAccent.withAlpha(180), // vaaleampi fill
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                mainText,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 6,
                      color: Colors.black,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
              Text(
                subText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//
// ─────────────────────────────
// UI HELPERS
// ─────────────────────────────
//

class _CardSurface extends StatelessWidget {
  final Widget child;
  const _CardSurface({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: child,
    );
  }
}

class _GradientCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget trailing;
  final Color gradientA;
  final Color gradientB;

  const _GradientCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.gradientA,
    required this.gradientB,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientA, gradientB],
        ),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                ),
                IconTheme(
                  data: IconThemeData(color: Colors.white.withAlpha(220)),
                  child: trailing,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withAlpha(165),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
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
        color: Colors.white.withAlpha(15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white.withAlpha(180)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withAlpha(220),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
