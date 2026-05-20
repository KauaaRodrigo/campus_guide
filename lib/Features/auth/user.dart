/// Modelo de usuário da aplicação.
///
/// Representa os dados principais de um usuário armazenados no backend.
/// Fornece um `fromMap` para construir a instância a partir de um documento
/// (ex.: Firebase) e `toMap` para serializar antes de persistir.
class AppUser {
  final String id;
  final String name;
  final String email;
  final String matricula;
  final String role;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.matricula,
    required this.role,
  });

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      matricula: data['matricula'] ?? '',
      role: data['role'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'email': email, 'matricula': matricula, 'role': role};
  }
}
