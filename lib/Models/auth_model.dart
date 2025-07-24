class AuthenticateModel {
  String? name;
  String email;
  String id;
  String role;
  String password;
  bool isChecked;

  AuthenticateModel(
      {this.name, required this.email, required this.id, required this.role, required this.password, required this.isChecked});

  factory AuthenticateModel.fromMap(Map<String, dynamic> map) {
    return AuthenticateModel(
      name: map['user_name'],
      email: map['user_email'],
      id: map['user_id'],
      role: map['user_role'],
      password: map['user_password'],
      isChecked: map['user_checked']
    );
  }

  Map<String, dynamic> toMap() => {
        'user_name': name,
        'user_email': email,
        'user_id': id,
        'user_role': role,
        'user_password': password,
        'user_checked': isChecked
      };
}
