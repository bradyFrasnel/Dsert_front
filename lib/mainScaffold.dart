// lib/main_scaffold.dart

import 'package:dsertmobile/component/couleur.dart';
import 'package:dsertmobile/model/convocation.dart';
import 'package:dsertmobile/model/employe.dart';
import 'package:dsertmobile/view/accueil.dart';
import 'package:dsertmobile/view/convocation.dart';
import 'package:dsertmobile/view/convocationListe.dart';
import 'package:dsertmobile/view/liste.dart';
import 'package:flutter/material.dart';

// Le MainScaffold est maintenant le widget principal qui contient la navigation.
// Il a besoin de savoir qui est l'utilisateur connecté.
class MainScaffold extends StatefulWidget {
  final Employe user;
  const MainScaffold({super.key, required this.user});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  // La liste des pages sera initialisée dans initState pour pouvoir passer `widget.user`.
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // On définit nos 3 pages principales ici.
    _pages = [
      Accueil(user: widget.user),
      const ListePage(),
      const ConvocationListePage(), // Page de liste des convocations
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Le body affiche la page sélectionnée dans la liste `_pages`.
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      // Notre barre de navigation.
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home), // Icône affichée quand l'onglet est actif
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Liste',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Convocations',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,

        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Couleur.principale,
        unselectedItemColor: Couleur.texteSecondaire,
        selectedFontSize: 12,
      ),
    );
  }
}
