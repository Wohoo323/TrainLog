import 'package:hive/hive.dart';
import '../models/workout.dart';

class WorkoutAdapter extends TypeAdapter<Workout> {
  @override
  final int typeId = 0;

  @override
  Workout read(BinaryReader reader) {
    final id = reader.readString();
    final typeIndex = reader.readInt();
    final duration = reader.readInt();
    final dateMillis = reader.readInt();
    final completed = reader.readBool();
    final caloriesExists = reader.readBool();
    final calories = caloriesExists ? reader.readDouble() : null;

    // details: voi olla null tai SwimDetails/GymDetails/RunDetails/BikeDetails
    final hasDetails = reader.readBool();
    final details = hasDetails ? (reader.read() as WorkoutDetails) : null;

    return Workout(
      id: id,
      type: WorkoutType.values[typeIndex],
      durationMinutes: duration,
      date: DateTime.fromMillisecondsSinceEpoch(dateMillis),
      completed: completed,
      caloriesBurned: calories,
      details: details,
    );
  }

  @override
  void write(BinaryWriter writer, Workout obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.type.index);
    writer.writeInt(obj.durationMinutes);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeBool(obj.completed);

    if (obj.caloriesBurned == null) {
      writer.writeBool(false);
    } else {
      writer.writeBool(true);
      writer.writeDouble(obj.caloriesBurned!);
    }

    if (obj.details == null) {
      writer.writeBool(false);
    } else {
      writer.writeBool(true);
      writer.write(obj.details); // Hive tallentaa oikean adapterin mukaan
    }
  }
}

