import 'package:hive/hive.dart';
import '../models/workout.dart';

class BikeDetailsAdapter extends TypeAdapter<BikeDetails> {
  @override
  final int typeId = 3;

  @override
  BikeDetails read(BinaryReader reader) {
    final distanceKm = reader.readDouble();
    final time = reader.readInt();
    return BikeDetails(distanceKm: distanceKm, timeMinutes: time);
  }

  @override
  void write(BinaryWriter writer, BikeDetails obj) {
    writer.writeDouble(obj.distanceKm);
    writer.writeInt(obj.timeMinutes);
  }
}
