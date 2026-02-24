import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/plan_item.dart';
import '../models/workout.dart';
import '../ui/workout_ui.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final _uuid = const Uuid();
  late final Box<PlanItem> _box;

  List<PlanItem> _items = [];

  @override
  void initState() {
    super.initState();
    // The box is already open from main.dart, just get the instance here
    _box = Hive.box<PlanItem>('plans');
    _load();
  }

  void _load() {
    setState(() {
      _items = _box.values.toList()
        ..sort((a, b) => a.plannedDate.compareTo(b.plannedDate));
    });
  }

  Future<void> _save(PlanItem item) async {
    await _box.put(item.id, item);
  }

  Future<void> _delete(String id) async {
    await _box.delete(id);
  }

  Future<void> _addPlan() async {
    final result = await Navigator.of(context).push<PlanItem>(
      MaterialPageRoute(builder: (_) => const _AddPlanScreen()),
    );

    if (result == null) return;

    final item = PlanItem(
      id: _uuid.v4(),
      type: result.type,
      plannedDate: result.plannedDate,
      durationMinutes: result.durationMinutes,
      note: result.note,
    );

    await _save(item);
    _load();
  }

  String _dateText(DateTime d) => '${d.day}.${d.month}.${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plan')),
      body: _items.isEmpty
          ? Center(
        child: Text(
          'No plans yet.\nTap + to plan a workout.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withAlpha(180)),
        ),
      )
          : ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, i) {
          final p = _items[i];
          final accent = WorkoutUI.color(p.type);

          return Dismissible(
            key: ValueKey(p.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Icon(Icons.delete),
            ),
            confirmDismiss: (_) async {
              return await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete plan?'),
                  content: const Text('This will remove it.'),
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
              await _delete(p.id);
              _load();
            },
            child: Card(
              child: ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent.withAlpha(40),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(WorkoutUI.icon(p.type), color: accent),
                ),
                title: Text(
                  '${WorkoutUI.label(p.type)} • ${p.durationMinutes} min',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  '${_dateText(p.plannedDate)}${p.note.isEmpty ? '' : ' • ${p.note}'}',
                  style: TextStyle(color: Colors.white.withAlpha(180)),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPlan,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddPlanScreen extends StatefulWidget {
  const _AddPlanScreen();

  @override
  State<_AddPlanScreen> createState() => _AddPlanScreenState();
}

class _AddPlanScreenState extends State<_AddPlanScreen> {
  WorkoutType _type = WorkoutType.gym;
  DateTime _date = DateTime.now();
  int _duration = 60;
  final _noteCtrl = TextEditingController();

  String _dateText(DateTime d) => '${d.day}.${d.month}.${d.year}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() => _date = picked);
  }

  void _save() {
    Navigator.of(context).pop(
      PlanItem(
        id: 'tmp',
        type: _type,
        plannedDate: _date,
        durationMinutes: _duration,
        note: _noteCtrl.text.trim(),
      ),
    );
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add plan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<WorkoutType>(
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
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(_dateText(_date)),
              trailing: const Icon(Icons.calendar_month_rounded),
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _duration.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Duration (minutes)'),
              onChanged: (v) => _duration = int.tryParse(v) ?? 60,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Save plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
