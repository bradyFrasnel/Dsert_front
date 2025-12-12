// lib/controller/user_controller.dart

import 'package:dsertmobile/model/employe.dart';
import 'package:dsertmobile/service/apiService.dart';
import 'package:flutter/material.dart';

// Enum pour représenter les différents états de la page
enum UserState { initial, loading, loaded, error }

class UserController with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Variables d'état privées
  List<Employe> _users = [];
  UserState _state = UserState.initial;
  String _errorMessage = '';

  // Getters publics pour que la vue puisse accéder aux données sans les modifier
  List<Employe> get users => _users;
  UserState get state => _state;
  String get errorMessage => _errorMessage;

  // Méthode principale pour charger les utilisateurs
  // Dans la classe UserController

  Future<void> fetchUsers() async {
    try {
      // 1. On passe à l'état de chargement
      _state = UserState.loading;
      notifyListeners(); // Notifie la vue qu'un changement a eu lieu

      // 2. On appelle le service pour récupérer les données
      _users = await _apiService.getUsers(); // CORRIGÉ : ajout des parenthèses

      // 3. Si tout va bien, on passe à l'état chargé
      _state = UserState.loaded;
    } catch (e) {
      // 4. En cas d'erreur, on passe à l'état d'erreur et on stocke le message
      _state = UserState.error;
      _errorMessage = 'Impossible de charger les utilisateurs. Veuillez réessayer.';
      print(e); // Affiche l'erreur technique dans la console pour le debug
    } finally {
      // 5. On notifie la vue une dernière fois pour qu'elle se redessine avec le nouvel état
      notifyListeners();
    }
  }

}
