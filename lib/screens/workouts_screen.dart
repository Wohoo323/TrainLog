import 'package:flutter/material.dart';
import 'package:train_log/screens/workout_details_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

import '../models/workout.dart';
import '../widgets/workout_card.dart';
import '../services/api_ninjas_service.dart';
import '../ui/workout_ui.dart';

import 'add_swim_screen.dart';
import 'add_gym_screen.dart';

class WorkoutsScreen extends StatefulWidget {
  final double weightKg;
  const WorkoutsScreen({super.key, required this.weightKg});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final List<Workout> _workouts = [];
  final _uuid = const Uuid();
  final _api = ApiNinjasService();

  late final Box<Workout> _box;

  @override
  void initState() {
    super.initState();
    _box = Hive.box<Workout>('workouts');
    _loadWorkouts();
  }

  /// Lataa boxin datan listaan ja sorttaa uusimmat ensin
  void _loadWorkouts() {
    setState(() {
      _workouts
        ..clear()
        ..addAll(_box.values);
      _workouts.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  /// Tallentaa / päivittää treenin Hiveen
  Future<void> _saveWorkout(Workout workout) async {
    await _box.put(workout.id, workout);
  }

  /// Poistaa treenin Hive:stä
  Future<void> _deleteWorkout(String id) async {
    await _box.delete(id);
  }

  /// Lisää uusi treeni (legacy: vain type + duration)
  void _addWorkout(WorkoutType type, int duration) {
    final workout = Workout(
      id: _uuid.v4(),
      type: type,
      durationMinutes: duration,
      date: DateTime.now(),
    );

    _saveWorkout(workout);
    _loadWorkouts();
  }

  /// Muuntaa treenityypin API Ninjas -aktiviteettitekstiksi
  String _activityForType(WorkoutType type) {
    switch (type) {
      case WorkoutType.gym:
        return 'weight lifting';
      case WorkoutType.swim:
        return 'swimming';
      case WorkoutType.run:
        return 'running';
      case WorkoutType.bike:
        return 'bicycling';
    }
  }

  /// Ruksi: tehty/ei tehty + kcal API:sta + tallennus Hiveen
  Future<void> _toggleCompleted(Workout workout) async {
    setState(() {
      workout.completed = !workout.completed;
    });

    // jos ruksi pois -> tyhjennä kcal
    if (!workout.completed) {
      setState(() {
        workout.caloriesBurned = null;
      });
      await _saveWorkout(workout);
      return;
    }

    // jos kcal jo olemassa, ei haeta uudestaan
    if (workout.caloriesBurned != null) {
      await _saveWorkout(workout);
      return;
    }

    // ✅ Varmistetaan että vain yksi snackbar näkyy kerrallaan
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(content: Text('Calculating calories...')),
    );

    final calories = await _api.caloriesBurned(
      activity: _activityForType(workout.type),
      durationMinutes: workout.durationMinutes,
      weightKg: widget.weightKg,
    );

    if (!mounted) return;
    messenger.hideCurrentSnackBar();

    if (calories == null) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(content: Text('API error: calories not available')),
      );
      await _saveWorkout(workout); // tallennetaan ainakin completed-tila
      return;
    }

    setState(() {
      workout.caloriesBurned = calories;
    });

    await _saveWorkout(workout);
  }

  /// UUSI: valitse treenityyppi → avaa tyyppikohtainen lomake
  void _openAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Add workout'),
          children: [
            // -------------------- SWIM --------------------
            SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(context);

                final SwimDetails? details = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddSwimScreen()),
                );

                if (details == null) return;

                final workout = Workout(
                  id: _uuid.v4(),
                  type: WorkoutType.swim,
                  durationMinutes: details.timeMinutes,
                  date: DateTime.now(),
                  details: details,
                );

                await _saveWorkout(workout);
                _loadWorkouts();
              },
              child: Row(
                children: [
                  Icon(WorkoutUI.icon(WorkoutType.swim)),
                  const SizedBox(width: 10),
                  const Text('Swim'),
                ],
              ),
            ),

            // -------------------- GYM --------------------
            SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(context);

                final GymDetails? details = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddGymScreen()),
                );

                if (details == null) return;

                // Gymiin laitetaan nyt 60 min oletuksena.
                final workout = Workout(
                  id: _uuid.v4(),
                  type: WorkoutType.gym,
                  durationMinutes: 60,
                  date: DateTime.now(),
                  details: details,
                );

                await _saveWorkout(workout);
                _loadWorkouts();
              },
              child: Row(
                children: [
                  Icon(WorkoutUI.icon(WorkoutType.gym)),
                  const SizedBox(width: 10),
                  const Text('Gym'),
                ],
              ),
            ),

            // -------------------- TEMP FALLBACK --------------------
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                _openLegacyAddDialog();
              },
              child: const Text('Other types (temporary)'),
            ),
          ],
        );
      },
    );
  }

  /// Vanha lisäysdialogi (type + duration) varalle
  void _openLegacyAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AddWorkoutDialog(onAdd: _addWorkout),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workouts')),
      body: _workouts.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fitness_center_rounded,
                size: 56,
                color: Colors.white.withOpacity(0.85),
              ),
              const SizedBox(height: 12),
              const Text(
                'No workouts yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tap + to add your first workout',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ],
          ),
        ),
      )
          : ListView.builder(
        itemCount: _workouts.length,
        itemBuilder: (ctx, i) {
          final workout = _workouts[i];

          return Dismissible(
            key: ValueKey(workout.id),
            direction: DismissDirection.horizontal,
            background: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Icon(Icons.delete),
            ),
            secondaryBackground: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Icon(Icons.delete),
            ),
            confirmDismiss: (direction) async {
              return await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete workout?'),
                  content: const Text('This will remove it permanently.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (_) async {
              final deleted = workout;

              await _deleteWorkout(workout.id);
              _loadWorkouts();

              if (!mounted) return;

              // ✅ TÄMÄ KORJAA: vanha snackbar pois ennen uutta
              final messenger = ScaffoldMessenger.of(context);
              messenger.hideCurrentSnackBar();

              messenger.showSnackBar(
                SnackBar(
                  content: const Text('Workout deleted'),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () async {
                      await _saveWorkout(deleted);
                      _loadWorkouts();
                    },
                  ),
                ),
              );
            },
            child: WorkoutCard(
              workout: workout,
              onToggleCompleted: () => _toggleCompleted(workout),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        WorkoutDetailsScreen(workout: workout),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddWorkoutDialog extends StatefulWidget {
  final void Function(WorkoutType, int) onAdd;

  const AddWorkoutDialog({super.key, required this.onAdd});

  @override
  State<AddWorkoutDialog> createState() => _AddWorkoutDialogState();
}

class _AddWorkoutDialogState extends State<AddWorkoutDialog> {
  WorkoutType _type = WorkoutType.gym;
  int _duration = 30;

  void _save() {
    widget.onAdd(_type, _duration);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add workout'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<WorkoutType>(
            value: _type,
            items: WorkoutType.values
                .map(
                  (t) => DropdownMenuItem(
                value: t,
                child: Text(t.name.toUpperCase()),
              ),
            )
                .toList(),
            onChanged: (v) => setState(() => _type = v!),
          ),
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Duration (minutes)'),
            onChanged: (v) => _duration = int.tryParse(v) ?? 30,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
