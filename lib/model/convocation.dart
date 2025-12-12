// lib/model/convocation.dart

import 'package:dsertmobile/model/employe.dart';

class Convocation {
  final String? id;
  final String titre;
  final String description;
  final DateTime dateConvocation;
  final String heureDebut;
  final String heureFin;
  final String lieu;
  final String? emetteurId;
  final List<Employe> participants;
  final String? conversationId;

  Convocation({
    this.id,
    required this.titre,
    required this.description,
    required this.dateConvocation,
    required this.heureDebut,
    required this.heureFin,
    required this.lieu,
    this.emetteurId,
    required this.participants,
    this.conversationId,
  });

  // Méthode pour convertir un objet Convocation en JSON à envoyer
  Map<String, dynamic> toJson() {
    return {
      'titre': titre,
      'description': description,
      // Convertit l'objet DateTime en chaîne de caractères au format ISO 8601
      'date_convocation': dateConvocation.toIso8601String(),
      'heure_debut': heureDebut,
      'heure_fin': heureFin,
      'lieu': lieu,
      // Transforme la liste d'objets Employe en une liste de JSON
      'participants': participants.map((p) => p.toJson()).toList(),
    };
  }

  // Factory pour créer un objet Convocation depuis une réponse JSON de l'API
  // (On suppose que la réponse aura une structure similaire)
  factory Convocation.fromJson(Map<String, dynamic> json) {
    var participantList = json['participants'] as List? ?? [];
    List<Employe> participants = participantList.map((p) => Employe.fromJson(p)).toList();

    return Convocation(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      // Convertit la chaîne de caractères ISO 8601 en objet DateTime
      dateConvocation: DateTime.parse(json['date_convocation']),
      heureDebut: json['heure_debut'],
      heureFin: json['heure_fin'],
      lieu: json['lieu'],
      emetteurId: json['emetteurId'],
      participants: participants,
      conversationId: json['conversationId'],
    );
  }
}

