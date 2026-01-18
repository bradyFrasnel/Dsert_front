import 'package:dsertmobile/component/couleur.dart';
import 'package:dsertmobile/model/employe.dart';
import 'package:dsertmobile/view/loginPage.dart'; // Pour la déconnexion
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Accueil extends StatefulWidget {
  final Employe user;
  const Accueil({super.key, required this.user});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  // Fonction de déconnexion propre
  Future<void> _logout() async {
    // Supprimer le token
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Couleur.principale,
        foregroundColor: Colors.white,
        elevation: 4.0,

        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),

        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 50.0,
              vertical: 15.0
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    //widget.user.prenom,
                    'D\'Sert',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        toolbarHeight: kToolbarHeight + 50, // Hauteur de l'appBar.
      ),

      // Le Drawer utilise les informations de 'widget.user'
      drawer: _buildDrawer(),
      body: widget.user.role == 'MANAGER' || widget.user.role == 'ADMIN'
          ? _buildManagerDashboard()
          : _buildEmployeDashboard(),
    );
  }

  // Widget pour le Drawer, pour garder le code propre
  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              widget.user.nomComplet,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(widget.user.email ?? 'Email non disponible'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.user.nomComplet.isNotEmpty ? widget.user.nomComplet[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 40.0, color: Couleur.principale),
              ),
            ),
            decoration: const BoxDecoration(
              color: Couleur.principale,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: const Text('Rôle'),
            subtitle: Text(widget.user.role ?? 'Non défini'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Couleur.erreur),
            title: const Text('Déconnexion'),
            onTap: _logout, // Appel de la fonction de déconnexion
          ),
        ],
      ),
    );
  }

  Widget _buildManagerDashboard() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildDashboardCard(
          icon: Icons.send_and_archive,
          iconColor: Couleur.avertissement,
          title: 'Nouvelle Convocation',
          subtitle: 'Créer et envoyer une convocation',
          onTap: () {
            // Logique pour naviguer vers la création de convocation
          },
        ),
      ],
    );
  }

  Widget _buildEmployeDashboard() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionTitle('Convocations en attente'),
        _buildConvocationItem(
            'Réunion projet D\'Sert', 'Date: 20/12/2025 - 10:00', Status.ActionRequired),
      ],
    );
  }

  // Widgets réutilisables

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
      {required IconData icon,
        required Color iconColor,
        required String title,
        required String subtitle,
        required VoidCallback onTap}) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Icon(icon, color: iconColor, size: 40),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        onTap: onTap,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget _buildConvocationItem(String title, String subtitle, Status status) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Icon(
          status == Status.ActionRequired ? Icons.warning_amber_rounded : Icons.check_circle,
          color: status == Status.ActionRequired ? Couleur.avertissement : Couleur.succes,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: () {},
      ),
    );
  }
}

enum Status { ActionRequired, Completed }

