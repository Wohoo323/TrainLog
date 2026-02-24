import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final double weightKg;
  final ValueChanged<double> onWeightChanged;

  const ProfileScreen({
    super.key,
    required this.weightKg,
    required this.onWeightChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.weightKg.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  void _save() {
    final text = _weightController.text.replaceAll(',', '.');
    final value = double.tryParse(text);

    if (value == null || value <= 0 || value > 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Syötä kelvollinen paino (esim. 95.0)')),
      );
      return;
    }

    widget.onWeightChanged(value);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paino tallennettu')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Omat tiedot',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Paino (kg)',
                hintText: 'esim. 95.0',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Tallenna'),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Nykyinen paino: ${widget.weightKg.toStringAsFixed(1)} kg',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
