import 'package:dsertmobile/component/couleur.dart';
import 'package:flutter/material.dart';

class BottomMenu extends StatefulWidget {
  // Optionnel mais recommandé : ajout d'un callback pour informer la page parente du changement
  final Function(int) onTabChange;

  const BottomMenu({
    super.key,
    required this.onTabChange,
  });

  @override
  State<BottomMenu> createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> {
  // --- AJOUT 1 ---
  // Variable pour stocker l'index de l'onglet actuellement sélectionné.
  // On commence par le premier onglet (index 0).
  int _selectedIndex = 0;

  // --- AJOUT 2 ---
  // Méthode qui sera appelée lorsque l'utilisateur appuiera sur un onglet.
  void _onItemTapped(int index) {
    setState(() {
      // On met à jour l'index sélectionné avec le nouvel index.
      _selectedIndex = index;
    });
    // On appelle la fonction passée en paramètre pour notifier la page parente.
    widget.onTabChange(index);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Couleur.principale,
      onTap: _onItemTapped,
      currentIndex: _selectedIndex,
      selectedItemColor: Couleur.secondaire,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      unselectedItemColor: Colors.white,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_outlined),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Liste des utilisateurs',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Paramètres',
        ),
      ],
    );
  }
}
