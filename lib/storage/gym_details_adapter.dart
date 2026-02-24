import 'package:hive/hive.dart';
import '../models/workout.dart';

class GymDetailsAdapter extends TypeAdapter<GymDetails> {
  @override
  final int typeId = 5;

  @override
  GymDetails read(BinaryReader reader) {
    final sessionName = reader.readString();
    final count = reader.readInt();
    final exercises = <GymExercise>[];
    for (var i = 0; i < count; i++) {
      exercises.add(reader.read() as GymExercise);
    }
    return GymDetails(sessionName: sessionName, exercises: exercises);
  }

  @override
  void write(BinaryWriter writer, GymDetails obj) {
    writer.writeString(obj.sessionName);
    writer.writeInt(obj.exercises.length);
    for (final e in obj.exercises) {
      writer.write(e); // vaatii GymExerciseAdapterin rekisteröinnin
    }
  }
}
