// lib/component/user_flip_card.dart

import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:dsertmobile/model/employe.dart';
import 'package:dsertmobile/component/couleur.dart';

class UserFlipCard extends StatelessWidget {
  final Employe user;
  final VoidCallback onShowDetails; // Pour garder l'appel à votre dialogue

  const UserFlipCard({
    super.key,
    required this.user,
    required this.onShowDetails,
  });

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      direction: FlipDirection.HORIZONTAL, // Direction de l'animation
      front: _buildFrontCard(), // La carte de face
      back: _buildBackCard(),   // La carte de dos
    );
  }

// Le recto de la carte (logique d'affichage de l'image ajoutée)
  Widget _buildFrontCard() {
    // On prépare le contenu du CircleAvatar
    Widget avatarWidget;

    // On vérifie si l'utilisateur a une URL d'image valide
    if (user.imageUrl != null && user.imageUrl!.isNotEmpty) {
      // Si OUI: on utilise un CircleAvatar avec une image réseau
      avatarWidget = CircleAvatar(
        radius: 25, // Un rayon défini pour une taille constante
        backgroundImage: NetworkImage(user.imageUrl!),
        // Affiche une icône d'erreur si l'image ne charge pas
        onBackgroundImageError: (exception, stackTrace) {
        },
        backgroundColor: Colors.grey.shade200,
      );
    } else {
      avatarWidget = CircleAvatar(
        radius: 25,
        backgroundColor: Couleur.secondaire.withOpacity(0.1),
        foregroundColor: Couleur.secondaire,
        child: Text(user.nomComplet.isNotEmpty ? user.nomComplet[0].toUpperCase() : '?'),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Center( // Center pour bien aligner le contenu
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

          leading: avatarWidget,

          title: Text(user.nomComplet, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(user.role ?? 'Rôle non défini'),
          trailing: const Icon(Icons.flip_rounded, color: Colors.grey),
        ),
      ),
    );
  }


  // Le verso de la carte (les détails)
  Widget _buildBackCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: Couleur.principale.withOpacity(0.95), // Une couleur de fond différente
      child: Center( // Center pour bien aligner le contenu
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          title: Text(
            'Email: ${user.email ?? 'Non fourni'}',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          subtitle: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Embauche: ${user.dateEmbauche?.toLocal().toString().split(' ')[0] ?? 'N/A'}',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
              Text(
                'Statut: ${user.actif == true ? 'Actif' : 'Inactif'}',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
            ],
          ),
          // Un bouton pour voir encore plus de détails via l'ancienne dialogue
          trailing: IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: onShowDetails,
          ),
        ),
      ),
    );
  }
}
