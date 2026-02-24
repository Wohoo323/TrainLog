import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../ui/workout_ui.dart';

class AddSwimScreen extends StatefulWidget {
  const AddSwimScreen({super.key});

  @override
  State<AddSwimScreen> createState() => _AddSwimScreenState();
}

class _AddSwimScreenState extends State<AddSwimScreen> {
  final _distanceCtrl = TextEditingController(text: '2000');
  final _timeCtrl = TextEditingController(text: '40');

  String _stroke = 'Freestyle';
  int _poolMeters = 25;

  @override
  void dispose() {
    _distanceCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final distance = int.tryParse(_distanceCtrl.text) ?? 0;
    final time = int.tryParse(_timeCtrl.text) ?? 0;

    if (distance <= 0 || time <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Give distance and time')),
      );
      return;
    }

    final details = SwimDetails(
      distanceMeters: distance,
      timeMinutes: time,
      stroke: _stroke,
      poolMeters: _poolMeters,
    );

    Navigator.of(context).pop(details);
  }

  @override
  Widget build(BuildContext context) {
    final accent = WorkoutUI.color(WorkoutType.swim);

    return Scaffold(
      appBar: AppBar(title: const Text('Add swim')),
      body: SafeArea(
        child: SingleChildScrollView(
          // ✅ tämä estää overflowin kun näppäimistö aukeaa
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.pool_rounded, color: accent),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Swim workout',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _distanceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Distance (meters)',
                  prefixIcon: Icon(Icons.straighten_rounded),
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _timeCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Time (minutes)',
                  prefixIcon: Icon(Icons.timer_outlined),
                ),
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _stroke,
                decoration: const InputDecoration(
                  labelText: 'Stroke',
                  prefixIcon: Icon(Icons.water_rounded),
                ),
                items: const [
                  DropdownMenuItem(value: 'Freestyle', child: Text('Freestyle')),
                  DropdownMenuItem(value: 'Backstroke', child: Text('Backstroke')),
                  DropdownMenuItem(value: 'Breaststroke', child: Text('Breaststroke')),
                  DropdownMenuItem(value: 'Butterfly', child: Text('Butterfly')),
                ],
                onChanged: (v) => setState(() => _stroke = v ?? 'Freestyle'),
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<int>(
                initialValue: _poolMeters,
                decoration: const InputDecoration(
                  labelText: 'Pool length',
                  prefixIcon: Icon(Icons.square_rounded),
                ),
                items: const [
                  DropdownMenuItem(value: 25, child: Text('25 m')),
                  DropdownMenuItem(value: 50, child: Text('50 m')),
                  DropdownMenuItem(value: 0, child: Text('Open water')),
                ],
                onChanged: (v) => setState(() => _poolMeters = v ?? 25),
              ),

              const SizedBox(height: 18),

              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Save swim'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

