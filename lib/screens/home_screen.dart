import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:train_log/screens/workout_details_screen.dart';

import '../models/workout.dart';

class HomeScreen extends StatelessWidget {
  final double weightKg;
  final VoidCallback onOpenProfile;

  const HomeScreen({
    super.key,
    required this.weightKg,
    required this.onOpenProfile,
  });

  DateTime _startOfWeek(DateTime d) {
    // Monday = 1 ... Sunday = 7
    final daysFromMonday = d.weekday - DateTime.monday;
    return DateTime(d.year, d.month, d.day).subtract(Duration(days: daysFromMonday));
  }

  bool _isInRangeInclusiveStart(DateTime date, DateTime start, DateTime endExclusive) {
    // start <= date < endExclusive
    return !date.isBefore(start) && date.isBefore(endExclusive);
  }

  @override
  Widget build(BuildContext context) {
    final workoutsBox = Hive.box<Workout>('workouts');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: onOpenProfile,
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder<Box<Workout>>(
          valueListenable: workoutsBox.listenable(),
          builder: (context, box, _) {
            final now = DateTime.now();
            final weekStart = _startOfWeek(now);
            final weekEnd = weekStart.add(const Duration(days: 7));

            // Workouts this week
            final workoutsThisWeek = box.values.where((w) {
              return _isInRangeInclusiveStart(w.date, weekStart, weekEnd);
            }).toList();

            final countThisWeek = workoutsThisWeek.length;
            const goal = 5;
            final progress = (countThisWeek / goal).clamp(0.0, 1.0);

            // Calories this week (only if calculated)
            final kcalThisWeek = workoutsThisWeek.fold<double>(
              0.0,
                  (sum, w) => sum + (w.caloriesBurned ?? 0.0),
            );

            // Latest workout
            Workout? latest;
            if (box.values.isNotEmpty) {
              final list = box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
              latest = list.first;
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                // ---------- TOP ----------
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Dashboard',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    _PillButton(
                      icon: Icons.edit_rounded,
                      label: 'Edit weight',
                      onTap: onOpenProfile,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ---------- CARDS GRID ----------
                Row(
                  children: [
                    Expanded(
                      child: _GradientCard(
                        title: 'Current weight',
                        subtitle: 'Used for calorie estimate',
                        gradientA: const Color(0xFF1E1B4B),
                        gradientB: const Color(0xFF0B0F1A),
                        trailing: const Icon(Icons.scale_outlined),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              weightKg.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'kg',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GradientCard(
                        title: 'Calories (week)',
                        subtitle: 'From completed workouts',
                        gradientA: const Color(0xFF0F172A),
                        gradientB: const Color(0xFF111827),
                        trailing: const Icon(Icons.local_fire_department_rounded),
                        child: Text(
                          kcalThisWeek > 0 ? '${kcalThisWeek.round()}' : '—',
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ---------- THIS WEEK BIG CARD ----------
                _CardSurface(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 92,
                          height: 92,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 10,
                                backgroundColor: Colors.white.withValues(alpha: 0.08),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$countThisWeek/$goal',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    'this week',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withValues(alpha: 0.7),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Workouts this week',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                countThisWeek >= goal
                                    ? 'Goal reached 🔥'
                                    : 'Keep going — ${goal - countThisWeek} to reach your goal',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
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
                                    text: '$countThisWeek done',
                                  ),
                                  _MiniChip(
                                    icon: Icons.flag_outlined,
                                    text: 'Goal $goal',
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

                // ---------- LAST WORKOUT ----------
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
                              color: Colors.white.withValues(alpha: 0.07),
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
                                  'Last workout',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  latest == null
                                      ? 'No workouts yet'
                                      : '${latest.type.name.toUpperCase()} • ${latest.durationMinutes} min',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.75),
                                    fontWeight: FontWeight.w700,
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

                const SizedBox(height: 14),

                // ---------- TIP ----------
                Text(
                  'Tip',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Mark workouts as completed to calculate calories with the API.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CardSurface extends StatelessWidget {
  final Widget child;
  const _CardSurface({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
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
    required this.child,
    required this.trailing,
    required this.gradientA,
    required this.gradientB,
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconTheme(
                  data: IconThemeData(color: Colors.white.withValues(alpha: 0.85)),
                  child: trailing,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
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
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.7)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PillButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
