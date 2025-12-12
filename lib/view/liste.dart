// lib/view/liste.dart

import 'package:dsertmobile/component/couleur.dart';
import 'package:dsertmobile/model/employe.dart';
import 'package:dsertmobile/service/apiService.dart';
import 'package:flutter/material.dart';

class ListePage extends StatefulWidget {
  const ListePage({super.key});

  @override
  State<ListePage> createState() => _ListePageState();
}

class _ListePageState extends State<ListePage> {
  late Future<List<Employe>> _futureEmployes;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // On charge les utilisateurs au démarrage de la page
    _futureEmployes = _apiService.getUsers();
  }

  // Méthode pour rafraîchir manuellement
  Future<void> _refreshUsers() async {
    setState(() {
      _futureEmployes = _apiService.getUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Employés'),
        backgroundColor: Couleur.principale,
        foregroundColor: Colors.white,
      ),
      // Le corps de la page qui affiche la liste
      body: RefreshIndicator(
        onRefresh: _refreshUsers,
        child: FutureBuilder<List<Employe>>(
          future: _futureEmployes,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aucun utilisateur trouvé.'));
            }

            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return _buildUserCard(users[index]);
              },
            );
          },
        ),
      ),
    );
  }

  // La carte pour chaque utilisateur
  Widget _buildUserCard(Employe user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(user.nomComplet.isNotEmpty ? user.nomComplet[0] : '?'),
        ),
        title: Text(user.nomComplet),
        subtitle: Text(user.role ?? 'Rôle non défini'),
        onLongPress: () { // L'appui long qui déclenche la dialog
          _showUserDetailsDialog(context, user);
        },
      ),
    );
  }

  // La boîte de dialogue
  void _showUserDetailsDialog(BuildContext context, Employe user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(user.nomComplet),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Email: ${user.email ?? 'Non fourni'}'),
                Text('Rôle: ${user.role ?? 'Non défini'}'),
                Text('Date d\'embauche: ${user.dateEmbauche?.toLocal().toString().split(' ')[0] ?? 'N/A'}'),
                Text('Statut: ${user.actif == true ? 'Actif' : 'Inactif'}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
