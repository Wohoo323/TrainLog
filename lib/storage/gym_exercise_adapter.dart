import 'package:hive/hive.dart';
import '../models/workout.dart';

class GymExerciseAdapter extends TypeAdapter<GymExercise> {
  @override
  final int typeId = 4;

  @override
  GymExercise read(BinaryReader reader) {
    final name = reader.readString();
    final sets = reader.readInt();
    final reps = reader.readInt();
    final weight = reader.readDouble();
    return GymExercise(name: name, sets: sets, reps: reps, weightKg: weight);
  }

  @override
  void write(BinaryWriter writer, GymExercise obj) {
    writer.writeString(obj.name);
    writer.writeInt(obj.sets);
    writer.writeInt(obj.reps);
    writer.writeDouble(obj.weightKg);
  }
}
