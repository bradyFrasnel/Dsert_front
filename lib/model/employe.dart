// lib/model/employe.dart

import 'dart:convert';

// Helper function to decode a list of Employe from a string
List<Employe> employeFromJson(String str) => List<Employe>.from(json.decode(str).map((x) => Employe.fromJson(x)));

// Helper function to encode a list of Employe to a string
String employeToJson(List<Employe> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Employe {
  final String? id;
  // 1. Remplacer 'nom' par 'nomFamille' et 'prenom' pour correspondre à l'API
  final String? nomFamille;
  final String? prenom;
  final String? email;
  final String? motDePasse;
  final String? role;
  final DateTime? dateEmbauche;
  final dynamic dateSortie; // Garder en 'dynamic' si ça peut être null
  final bool? actif;

  Employe({
    this.id,
    this.nomFamille,
    this.prenom,
    this.email,
    this.motDePasse,
    this.role,
    this.dateEmbauche,
    this.dateSortie,
    this.actif,
  });

  // 2. Créer un "getter" pour avoir le nom complet facilement
  // Il combine le prénom et le nom de famille.
  // Les '?? ''' servent à éviter les erreurs si l'un des deux est null.
  String get nomComplet {
    return '${prenom ?? ''} ${nomFamille ?? ''}'.trim();
  }

  // 3. Mettre à jour la factory 'fromJson' pour utiliser les bons champs
  factory Employe.fromJson(Map<String, dynamic> json) => Employe(
    id: json["id"],
    nomFamille: json["nomFamille"],
    prenom: json["prenom"],
    email: json["email"],
    motDePasse: json["motDePasse"],
    role: json["role"],
    dateEmbauche: json["dateEmbauche"] == null ? null : DateTime.parse(json["dateEmbauche"]),
    dateSortie: json["dateSortie"],
    actif: json["actif"],
  );

  // Mettre à jour la méthode 'toJson' (utile si vous envoyez des données)
  Map<String, dynamic> toJson() => {
    "id": id,
    "nomFamille": nomFamille,
    "prenom": prenom,
    "email": email,
    "motDePasse": motDePasse,
    "role": role,
    "dateEmbauche": dateEmbauche?.toIso8601String(),
    "dateSortie": dateSortie,
    "actif": actif,
  };
}
