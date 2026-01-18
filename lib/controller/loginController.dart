import 'package:dsertmobile/service/apiService.dart';

class LoginController {
  final ApiService _apiService = ApiService();

  // Elle retourne directement le résultat de l'ApiService.
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      // Appelle le service et attend la réponse.
      print('LoginController: Tentative de connexion pour $email et $password');
      final result = await _apiService.login(email, password);

      // Si le service a retourné un résultat (sans lancer d'erreur), on le retourne à la vue.
      print('LoginController: Connexion réussie, retour du résultat à la vue.');
      return result;

    } catch (e) {
      // Si le service a lancé une erreur (ex: 401, timeout, etc.),
      // on la "relance" pour que la vue (loginPage) puisse l'attraper dans son propre bloc try-catch.
      print('LoginController: Erreur reçue du service: $e');
      rethrow;
    }
  }
}