import 'package:hive/hive.dart';
import '../models/workout.dart';

class RunDetailsAdapter extends TypeAdapter<RunDetails> {
  @override
  final int typeId = 2;

  @override
  RunDetails read(BinaryReader reader) {
    final distanceKm = reader.readDouble();
    final time = reader.readInt();
    return RunDetails(distanceKm: distanceKm, timeMinutes: time);
  }

  @override
  void write(BinaryWriter writer, RunDetails obj) {
    writer.writeDouble(obj.distanceKm);
    writer.writeInt(obj.timeMinutes);
  }
}
