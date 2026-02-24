import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/workout.dart';
import 'models/plan_item.dart';

import 'storage/workout_adapter.dart';
import 'storage/plan_item_adapter.dart';
import 'storage/swim_details_adapter.dart';
import 'storage/run_details_adapter.dart';
import 'storage/bike_details_adapter.dart';
import 'storage/gym_exercise_adapter.dart';
import 'storage/gym_details_adapter.dart';

import 'screens/home_screen.dart';
import 'screens/workouts_screen.dart';
import 'screens/plan_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Adapterit
  if (!Hive.isAdapterRegistered(WorkoutAdapter().typeId)) {
    Hive.registerAdapter(WorkoutAdapter());
  }
  if (!Hive.isAdapterRegistered(SwimDetailsAdapter().typeId)) {
    Hive.registerAdapter(SwimDetailsAdapter());
  }
  if (!Hive.isAdapterRegistered(RunDetailsAdapter().typeId)) {
    Hive.registerAdapter(RunDetailsAdapter());
  }
  if (!Hive.isAdapterRegistered(BikeDetailsAdapter().typeId)) {
    Hive.registerAdapter(BikeDetailsAdapter());
  }
  if (!Hive.isAdapterRegistered(GymExerciseAdapter().typeId)) {
    Hive.registerAdapter(GymExerciseAdapter());
  }
  if (!Hive.isAdapterRegistered(GymDetailsAdapter().typeId)) {
    Hive.registerAdapter(GymDetailsAdapter());
  }
  if (!Hive.isAdapterRegistered(PlanItemAdapter().typeId)) {
    Hive.registerAdapter(PlanItemAdapter());
  }

  // Boxit
  if (!Hive.isBoxOpen('workouts')) {
    await Hive.openBox<Workout>('workouts');
  }
  if (!Hive.isBoxOpen('settings')) {
    await Hive.openBox('settings');
  }
  if (!Hive.isBoxOpen('plans')) {
    await Hive.openBox<PlanItem>('plans');
  }

  runApp(const TrainLogApp());
}

class TrainLogApp extends StatelessWidget {
  const TrainLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrainLog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C3AED),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0B0F1A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B0F1A),
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF121A2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  double _weightKg = 95.0;

  @override
  void initState() {
    super.initState();
    final settings = Hive.box('settings');
    _weightKg =
        (settings.get('weightKg', defaultValue: 95.0) as num).toDouble();
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          weightKg: _weightKg,
          onWeightChanged: (newWeight) {
            setState(() => _weightKg = newWeight);
            Hive.box('settings').put('weightKg', newWeight);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (_index) {
      case 0:
        page = HomeScreen(
          weightKg: _weightKg,
          onOpenProfile: _openProfile,
        );
        break;
      case 1:
        page = WorkoutsScreen(weightKg: _weightKg);
        break;
      case 2:
        page = const PlanScreen();
        break;
      default:
        page = const StatsScreen();
    }

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      child: Icon(Icons.fitness_center_rounded),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TrainLog',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Weight ${_weightKg.toStringAsFixed(1)} kg',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),

              _DrawerItem(
                icon: Icons.home_outlined,
                label: 'Home',
                selected: _index == 0,
                onTap: () {
                  setState(() => _index = 0);
                  Navigator.pop(context);
                },
              ),
              _DrawerItem(
                icon: Icons.fitness_center_outlined,
                label: 'Workouts',
                selected: _index == 1,
                onTap: () {
                  setState(() => _index = 1);
                  Navigator.pop(context);
                },
              ),
              _DrawerItem(
                icon: Icons.calendar_month_outlined,
                label: 'Plan',
                selected: _index == 2,
                onTap: () {
                  setState(() => _index = 2);
                  Navigator.pop(context);
                },
              ),
              _DrawerItem(
                icon: Icons.bar_chart_outlined,
                label: 'Stats',
                selected: _index == 3,
                onTap: () {
                  setState(() => _index = 3);
                  Navigator.pop(context);
                },
              ),

              const Spacer(),
              const Divider(),

              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  _openProfile();
                },
              ),
            ],
          ),
        ),
      ),

      body: SafeArea(child: page),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined), label: 'Workouts'),
          NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined), label: 'Plan'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined), label: 'Stats'),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
        ),
      ),
      selected: selected,
      onTap: onTap,
    );
  }
}
