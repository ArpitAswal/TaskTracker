/* To store objects in Hive, you need to register a TypeAdapter. This is done by generating a class that extends
TypeAdapter<T>. Let's create and register the adapter:
 */

import 'package:hive/hive.dart';

import '../Models/todo_model.dart';

class TodoAdapter extends TypeAdapter<TodoModel> {
  @override
  final typeId = 0; // Unique ID for the adapter

  @override
  TodoModel read(BinaryReader reader) {
    // Define how to read the object from the binary
    return TodoModel(
      title: reader.readString(),
      description: reader.readString(),
      isCompleted: reader.readBool(),
      id: reader.readInt(),
      startDate: DateTime.parse(reader.readString()),
      endDate: DateTime.parse(reader.readString()),
      createdAtTime: DateTime.parse(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, TodoModel obj) {
    // Define how to write the object to binary
    writer.writeString(obj.title);
    writer.writeString(obj.description);
    writer.writeBool(obj.isCompleted);
    writer.writeInt(obj.id);
    writer.writeString(obj.startDate.toString());
    writer.writeString(obj.endDate.toString());
    writer.writeString(obj.createdAtTime.toString());
  }
}
