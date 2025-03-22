class AuthenticateModel {
  String? name;
  String email;
  String id;
  String role;

  AuthenticateModel(
      {this.name, required this.email, required this.id, required this.role});

  factory AuthenticateModel.fromMap(Map<String, dynamic> map) {
    return AuthenticateModel(
      name: map['user_name'],
      email: map['user_email'],
      id: map['user_id'],
      role: map['user_role'],
    );
  }

  Map<String, dynamic> toMap() => {
        'user_name': name,
        'user_email': email,
        'user_id': id,
        'user_role': role,
      };
}
