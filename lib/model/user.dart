// lib/model/user.dart

class User {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String role;

  User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
  });

  // Cette fonction est cruciale, elle transforme le JSON en objet User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      role: json['role'],
      // S'assurer que chaque clé ici ('id', 'nom', etc.) existe dans l'objet 'employe' de l'API
    );
  }
}
