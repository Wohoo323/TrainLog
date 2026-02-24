import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../ui/workout_ui.dart';

class AddGymScreen extends StatefulWidget {
  const AddGymScreen({super.key});

  @override
  State<AddGymScreen> createState() => _AddGymScreenState();
}

class _AddGymScreenState extends State<AddGymScreen> {
  final _nameCtrl = TextEditingController(text: 'Leg day');
  final List<GymExercise> _exercises = [];

  // lisää yksi liike dialogilla
  Future<void> _addExercise() async {
    final result = await showDialog<GymExercise>(
      context: context,
      builder: (_) => const _AddExerciseDialog(),
    );
    if (result == null) return;

    setState(() {
      _exercises.add(result);
    });
  }

  double get _totalVolume =>
      _exercises.fold(0.0, (sum, e) => sum + e.volume);

  void _save() {
    final sessionName = _nameCtrl.text.trim();
    if (sessionName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Give the workout a name')),
      );
      return;
    }
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one exercise')),
      );
      return;
    }

    final details = GymDetails(
      sessionName: sessionName,
      exercises: List.of(_exercises),
    );

    Navigator.of(context).pop(details);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = WorkoutUI.color(WorkoutType.gym);

    return Scaffold(
      appBar: AppBar(title: const Text('Gym workout')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          children: [
            // Yläkortti: total volume
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
                      child:
                      Icon(WorkoutUI.icon(WorkoutType.gym), color: accent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total volume',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${_totalVolume.round()} kg',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${_exercises.length} ex',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Nimi + add button
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Workout name',
                        prefixIcon: Icon(Icons.title_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _addExercise,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add exercise'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Liikelista
            Expanded(
              child: _exercises.isEmpty
                  ? Center(
                child: Text(
                  'No exercises yet.\nTap "Add exercise".',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
              )
                  : ListView.builder(
                itemCount: _exercises.length,
                itemBuilder: (context, i) {
                  final e = _exercises[i];

                  return Dismissible(
                    key: ValueKey('${e.name}-$i'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Icon(Icons.delete),
                    ),
                    onDismissed: (_) {
                      setState(() {
                        _exercises.removeAt(i);
                      });
                    },
                    child: Card(
                      child: ListTile(
                        title: Text(
                          e.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        subtitle: Text(
                          '${e.sets} x ${e.reps} @ ${e.weightKg.toStringAsFixed(1)} kg',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                          ),
                        ),
                        trailing: Text(
                          '${e.volume.round()} kg',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Save
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Save gym workout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddExerciseDialog extends StatefulWidget {
  const _AddExerciseDialog();

  @override
  State<_AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<_AddExerciseDialog> {
  final _nameCtrl = TextEditingController();
  final _setsCtrl = TextEditingController(text: '3');
  final _repsCtrl = TextEditingController(text: '8');
  final _weightCtrl = TextEditingController(text: '60');

  void _save() {
    final name = _nameCtrl.text.trim();
    final sets = int.tryParse(_setsCtrl.text) ?? 0;
    final reps = int.tryParse(_repsCtrl.text) ?? 0;
    final weight = double.tryParse(_weightCtrl.text) ?? 0;

    if (name.isEmpty || sets <= 0 || reps <= 0 || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill all fields correctly')),
      );
      return;
    }

    Navigator.of(context).pop(
      GymExercise(name: name, sets: sets, reps: reps, weightKg: weight),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _setsCtrl.dispose();
    _repsCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add exercise'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Exercise name'),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _setsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Sets'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _repsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Reps'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _weightCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Weight (kg)'),
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
          child: const Text('Add'),
        ),
      ],
    );
  }
}
