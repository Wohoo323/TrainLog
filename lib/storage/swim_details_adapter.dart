import 'package:hive/hive.dart';
import '../models/workout.dart';

class SwimDetailsAdapter extends TypeAdapter<SwimDetails> {
  @override
  final int typeId = 1;

  @override
  SwimDetails read(BinaryReader reader) {
    final distance = reader.readInt();
    final time = reader.readInt();
    final pool = reader.readInt();
    final stroke = reader.readString();
    return SwimDetails(
      distanceMeters: distance,
      timeMinutes: time,
      poolMeters: pool,
      stroke: stroke,
    );
  }

  @override
  void write(BinaryWriter writer, SwimDetails obj) {
    writer.writeInt(obj.distanceMeters);
    writer.writeInt(obj.timeMinutes);
    writer.writeInt(obj.poolMeters);
    writer.writeString(obj.stroke);
  }
}
