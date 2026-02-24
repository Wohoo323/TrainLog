import 'package:hive/hive.dart';
import 'workout.dart';



@HiveType(typeId: 6)
class PlanItem {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final WorkoutType type;

  @HiveField(2)
  final DateTime plannedDate;

  @HiveField(3)
  final int durationMinutes;

  @HiveField(4)
  final String note;

  PlanItem({
    required this.id,
    required this.type,
    required this.plannedDate,
    required this.durationMinutes,
    required this.note,
  });
}
