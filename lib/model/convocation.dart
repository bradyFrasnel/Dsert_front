// lib/model/convocation.dart

import 'package:dsertmobile/model/employe.dart';

enum ConvocationStatut {
  enAttente('EN_ATTENTE'),
  acceptee('ACCEPTE'),
  refusee('REFUSEE'),
  annulee('ANNULEE');

  const ConvocationStatut(this.value);
  final String value;
}

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
  final ConvocationStatut statut;
  final DateTime createdAt;
  final bool avecChat;

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
    this.statut = ConvocationStatut.enAttente,
    required this.createdAt,
    this.avecChat = false,
  });

  // Méthode pour convertir un objet Convocation en JSON à envoyer
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'titre': titre,
      'description': description,
      // Convertit l'objet DateTime en chaîne de caractères au format ISO 8601
      'date_convocation': dateConvocation.toIso8601String(),
      'heure_debut': heureDebut,
      'heure_fin': heureFin,
      'lieu': lieu,
      if (emetteurId != null) 'emetteurId': emetteurId,
      // Transforme la liste d'objets Employe en une liste de JSON
      'participants': participants.map((p) => p.toJson()).toList(),
      if (conversationId != null) 'conversationId': conversationId,
      'statut': statut.value,
      'created_at': createdAt.toIso8601String(),
      'avecChat': avecChat,
    };
  }

  // Factory pour créer un objet Convocation depuis une réponse JSON de l'API
  factory Convocation.fromJson(Map<String, dynamic> json) {
    var participantList = json['participants'] as List? ?? [];
    List<Employe> participants = participantList.map((p) => Employe.fromJson(p)).toList();

    // Gérer le statut avec enum
    ConvocationStatut statut = ConvocationStatut.enAttente;
    if (json['statut'] != null) {
      statut = ConvocationStatut.values.firstWhere(
        (s) => s.value == json['statut'],
        orElse: () => ConvocationStatut.enAttente,
      );
    }

    return Convocation(
      id: json['id'],
      titre: json['titre'] ?? '',
      description: json['description'] ?? '',
      // Convertit la chaîne de caractères ISO 8601 en objet DateTime
      dateConvocation: DateTime.parse(json['date_convocation']),
      heureDebut: json['heure_debut'] ?? '',
      heureFin: json['heure_fin'] ?? '',
      lieu: json['lieu'] ?? '',
      emetteurId: json['emetteurId'],
      participants: participants,
      conversationId: json['conversationId'],
      statut: statut,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      avecChat: json['avecChat'] ?? false,
    );
  }

  // Méthodes utilitaires
  String get dateFormatee {
    final jour = dateConvocation.day.toString().padLeft(2, '0');
    final mois = dateConvocation.month.toString().padLeft(2, '0');
    final annee = dateConvocation.year;
    return '$jour/$mois/$annee';
  }

  String get heureRange => '$heureDebut - $heureFin';

  bool get estPassee => dateConvocation.isBefore(DateTime.now());

  bool get estAujourdhui {
    final maintenant = DateTime.now();
    return dateConvocation.day == maintenant.day &&
           dateConvocation.month == maintenant.month &&
           dateConvocation.year == maintenant.year;
  }

  // Copie avec modification
  Convocation copyWith({
    String? id,
    String? titre,
    String? description,
    DateTime? dateConvocation,
    String? heureDebut,
    String? heureFin,
    String? lieu,
    String? emetteurId,
    List<Employe>? participants,
    String? conversationId,
    ConvocationStatut? statut,
    DateTime? createdAt,
    bool? avecChat,
  }) {
    return Convocation(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      dateConvocation: dateConvocation ?? this.dateConvocation,
      heureDebut: heureDebut ?? this.heureDebut,
      heureFin: heureFin ?? this.heureFin,
      lieu: lieu ?? this.lieu,
      emetteurId: emetteurId ?? this.emetteurId,
      participants: participants ?? this.participants,
      conversationId: conversationId ?? this.conversationId,
      statut: statut ?? this.statut,
      createdAt: createdAt ?? this.createdAt,
      avecChat: avecChat ?? this.avecChat,
    );
  }

  @override
  String toString() {
    return 'Convocation(id: $id, titre: $titre, date: $dateFormatee, statut: $statut)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Convocation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

