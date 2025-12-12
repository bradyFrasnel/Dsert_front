import 'dart:async';
import 'dart:convert';
import 'package:dsertmobile/model/convocation.dart';
import 'package:dsertmobile/model/employe.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 1. IMPORTER flutter_secure_storage
import 'package:http/http.dart' as http;

class ApiService {
  // URL & Temps de la requête
  //static const String _baseUrl = 'http://10.0.2.2:4000';
  static const String _baseUrl = 'http://192.168.1.66:4000';
  final Duration _timeout = const Duration(seconds: 15);

  //SECURE STORAGE
  final _storage = const FlutterSecureStorage();

  // SINGLETON
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  //MÉTHODES PRIVÉES DE GESTION DU TOKEN
  Future<void> _saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<String?> _getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> logout() async {
    // Méthode pour se déconnecter
    await _storage.delete(key: 'jwt_token');
  }

  // --- HEADERS (MAINTENANT ASYNCHRONE) ---
  // 3. Le getter _headers est maintenant une méthode asynchrone pour lire le token
  Future<Map<String, String>> _getHeaders() async {
    String? token = await _getToken();
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // --- GESTION DES RÉPONSES ---
  dynamic _handleResponse(http.Response response) {
    if (response.body.isEmpty) {
      throw Exception('Réponse vide du serveur (Statut: ${response.statusCode})');
    }
    final responseBody = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else {
      throw Exception(responseBody['message'] ?? 'Erreur serveur inconnue');
    }
  }

  // --- MÉTHODE DE REQUÊTE GÉNÉRIQUE (MISE À JOUR) ---
  Future<dynamic> _request(String method, String endpoint, {dynamic body}) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final requestHeaders = await _getHeaders(); // 4. On récupère les headers de manière asynchrone

      print('API Request: $method $uri');
      // Ne pas afficher le token dans les logs en production
      // print('Headers: $requestHeaders');
      if (body != null) print('Body: ${json.encode(body)}');

      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: requestHeaders).timeout(_timeout);
          break;
        case 'POST':
          response = await http.post(uri, headers: requestHeaders, body: json.encode(body)).timeout(_timeout);
          break;
        default:
          throw Exception('Méthode HTTP non supportée: $method');
      }

      print('API Response (${response.statusCode}): ${response.body}');
      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('Le serveur ne répond pas. Vérifiez votre connexion.');
    } catch (e) {
      print('API Error for $method $endpoint: $e');
      rethrow;
    }
  }

  /// Authentifie un utilisateur et retourne un token et les infos de l'utilisateur.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _request(
      'POST',
      '/api/auth/login',
      body: {'email': email, 'motDePasse': password},
    );

    // 5. SAUVEGARDER LE TOKEN APRÈS UN LOGIN RÉUSSI
    if (response['access_token'] != null) {
      await _saveToken(response['access_token']);
    }

    return {
      'success': true,
      'token': response['access_token'],
      'user': response['employe'],
    };
  }

  /// Crée une nouvelle convocation.
  Future<void> createConvocation(Convocation convocation) async {
    await _request(
      'POST',
      '/api/convocations',
      body: convocation.toJson(),
    );
  }

  /// Récupère la liste de tous les utilisateurs (employés).
  Future<List<Employe>> getUsers() async {
    final Map<String, dynamic> response = await _request('GET', '/api/employes');
    final List<dynamic> responseData = response['data'];
    return responseData.map((json) => Employe.fromJson(json)).toList();
  }
}
