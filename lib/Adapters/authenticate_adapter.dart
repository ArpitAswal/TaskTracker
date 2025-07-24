import 'package:hive/hive.dart';
import '../Models/auth_model.dart';

class AuthenticateAdapter extends TypeAdapter<AuthenticateModel> {
  @override
  final typeId = 1;

  @override
  AuthenticateModel read(BinaryReader reader) {
    return AuthenticateModel(
      name: reader.readString(),
      email: reader.readString(),
      id: reader.readString(),
      role: reader.readString(),
      password: reader.readString(),
      isChecked: reader.readBool()
    );
  }

  @override
  void write(BinaryWriter writer, AuthenticateModel obj) {
    writer.writeString(obj.name ?? "NA");
    writer.writeString(obj.email);
    writer.writeString(obj.id);
    writer.writeString(obj.role);
    writer.writeString(obj.password);
    writer.writeBool(obj.isChecked);
  }
}
