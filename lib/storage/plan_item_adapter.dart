import 'package:hive/hive.dart';
import '../models/plan_item.dart';
import '../models/workout.dart';

class PlanItemAdapter extends TypeAdapter<PlanItem> {
  @override
  final int typeId = 6;

  @override
  PlanItem read(BinaryReader reader) {
    final id = reader.readString();
    final typeIndex = reader.readInt();
    final plannedDateMs = reader.readInt();
    final durationMinutes = reader.readInt();
    final note = reader.readString();

    return PlanItem(
      id: id,
      type: WorkoutType.values[typeIndex],
      plannedDate: DateTime.fromMillisecondsSinceEpoch(plannedDateMs),
      durationMinutes: durationMinutes,
      note: note,
    );
  }

  @override
  void write(BinaryWriter writer, PlanItem obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.type.index);
    writer.writeInt(obj.plannedDate.millisecondsSinceEpoch);
    writer.writeInt(obj.durationMinutes);
    writer.writeString(obj.note);
  }
}
