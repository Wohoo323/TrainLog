import 'package:hive/hive.dart';



// Treenityypit
enum WorkoutType { gym, swim, run, bike }

/// Base-luokka treenin lisätiedoille.
/// Tätä ei tallenneta suoraan, vaan aina konkreettinen tyyppi (SwimDetails jne).
abstract class WorkoutDetails {}

/// Uinti: matka + aika + tyyli + allas + pace
class SwimDetails extends WorkoutDetails {
  final int distanceMeters; // esim 2000
  final int timeMinutes; // esim 50
  final int poolMeters; // 25 tai 50
  final String stroke; // "Freestyle" / "Breaststroke" jne

  SwimDetails({
    required this.distanceMeters,
    required this.timeMinutes,
    required this.poolMeters,
    required this.stroke,
  });

  /// Pace min / 100m (esim 2.5)
  double get pacePer100 {
    if (distanceMeters <= 0) return 0;
    return (timeMinutes / (distanceMeters / 100.0));
  }
}

/// Juoksu: matka + aika + pace
class RunDetails extends WorkoutDetails {
  final double distanceKm;
  final int timeMinutes;

  RunDetails({
    required this.distanceKm,
    required this.timeMinutes,
  });

  /// Pace min/km
  double get pacePerKm {
    if (distanceKm <= 0) return 0;
    return timeMinutes / distanceKm;
  }
}

/// Pyöräily: matka + aika + keskinopeus
class BikeDetails extends WorkoutDetails {
  final double distanceKm;
  final int timeMinutes;

  BikeDetails({
    required this.distanceKm,
    required this.timeMinutes,
  });

  /// km/h
  double get avgSpeedKmh {
    if (timeMinutes <= 0) return 0;
    final hours = timeMinutes / 60.0;
    return distanceKm / hours;
  }
}

/// Yksi liike salilla
class GymExercise {
  final String name;
  final int sets;
  final int reps;
  final double weightKg;

  GymExercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.weightKg,
  });

  double get volume => sets * reps * weightKg;
}

/// Sali: treenin nimi + liikelista
class GymDetails extends WorkoutDetails {
  final String sessionName;
  final List<GymExercise> exercises;

  GymDetails({
    required this.sessionName,
    required this.exercises,
  });

  double get totalVolume =>
      exercises.fold(0.0, (sum, e) => sum + e.volume);

  int get exerciseCount => exercises.length;
}

/// Workout = perusdata + details (tyypin mukaan)
class Workout {
  final String id;
  final WorkoutType type;
  final int durationMinutes;
  final DateTime date;

  bool completed;
  double? caloriesBurned;

  /// TÄRKEÄ: tänne tallennetaan SwimDetails / GymDetails / RunDetails / BikeDetails
  final WorkoutDetails? details;

  Workout({
    required this.id,
    required this.type,
    required this.durationMinutes,
    required this.date,
    this.completed = false,
    this.caloriesBurned,
    this.details,
  });
}
