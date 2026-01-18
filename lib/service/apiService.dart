import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dsertmobile/model/convocation.dart';
import 'package:dsertmobile/model/employe.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // URL & Temps de la requête
  static const String _baseUrl = 'http://10.0.2.2:4000';
  //static const String _baseUrl = 'http://192.168.0.111:4000';
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

  //HEADERS (MAINTENANT ASYNCHRONE)
  //e getter _headers est maintenant une méthode asynchrone pour lire le token
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

  //GESTION DES RÉPONSES
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

  //MÉTHODE DE REQUÊTE (MISE À JOUR)
  Future<dynamic> _request(String method, String endpoint, {dynamic body}) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final requestHeaders = await _getHeaders(); //On récupère les headers de manière asynchrone

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
        case 'PUT':
          response = await http.put(uri, headers: requestHeaders, body: json.encode(body)).timeout(_timeout);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: requestHeaders).timeout(_timeout);
          break;
        case 'PATCH':
          response = await http.patch(uri, headers: requestHeaders, body: json.encode(body)).timeout(_timeout);
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
      body: {'email': email, 'password': password},
    );

    //SAUVEGARDER LE TOKEN APRÈS UN LOGIN RÉUSSI
    if (response['access_token'] != null) {
      await _saveToken(response['access_token']);
    }

    return {
      'success': true,
      'token': response['access_token'],
      'user': response['employe'],
    };
  }

  /// Créer un compte utilisateur (méthode register optimisée pour l'API NestJS)
  Future<Employe> register({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    required String role,
    File? imageFile,
  }) async {
    try {
      // Étape 1: Créer l'employé avec JSON simple
      final response = await _request(
        'POST',
        '/api/auth/register',
        body: {
          'nomFamille': nom.trim(),
          'prenom': prenom.trim(),
          'email': email.trim(),
          'password': password,
          'role': role.toLowerCase(), // 'employe' ou 'manager'
        },
      );

      final Map<String, dynamic> responseData = response;
      
      // Sauvegarder le token d'accès
      if (responseData['access_token'] != null) {
        await _saveToken(responseData['access_token']);
      }

      final employe = Employe.fromJson(responseData['employe']);

      // Étape 2: Ajouter la photo si fournie (optionnel, ne bloque pas l'inscription)
      if (imageFile != null && employe.id != null) {
        try {
          await _uploadEmployeePhoto(employe.id!, imageFile);
        } catch (e) {
          print('Erreur upload photo (non bloquante): $e');
          // Ne pas bloquer l'inscription si l'upload échoue
        }
      }

      return employe;
    } catch (e) {
      print('Erreur API Register: $e');
      rethrow;
    }
  }

  /// Upload la photo de profil d'un employé (endpoint séparé)
  Future<void> _uploadEmployeePhoto(String employeeId, File imageFile) async {
    try {
      // Validation de la taille du fichier (max 5 MB = 5 242 880 octets)
      final fileSize = await imageFile.length();
      if (fileSize > 5242880) {
        throw Exception('La taille du fichier ne doit pas dépasser 5MB');
      }

      // Validation du type de fichier (JPEG, PNG)
      final fileName = imageFile.path.toLowerCase();
      if (!fileName.endsWith('.jpeg') && 
          !fileName.endsWith('.jpg') && 
          !fileName.endsWith('.png')) {
        throw Exception('Type de fichier non pris en charge. Veuillez télécharger une image (JPEG, PNG)');
      }

      final uri = Uri.parse('$_baseUrl/api/employes/$employeeId/photo');
      var request = http.MultipartRequest('POST', uri);

      // Le champ DOIT s'appeler "file" selon la spécification API
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final headers = await _getHeaders();
      headers.remove('Content-Type'); // Important pour multipart
      request.headers.addAll(headers);

      final streamedResponse = await request.send().timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200 && response.statusCode != 201) {
        final responseBody = json.decode(response.body);
        throw Exception(responseBody['message'] ?? 'Erreur upload photo: ${response.body}');
      }
    } catch (e) {
      print('Erreur upload photo: $e');
      rethrow;
    }
  }

  /// Récupère la liste de tous les utilisateurs (format standardisé)
  Future<Map<String, dynamic>> getUsers() async {
    final response = await _request('GET', '/api/employes');
    
    // Standardiser la réponse : l'API peut retourner {"data": [...]} ou directement une liste
    if (response is Map && response.containsKey('data')) {
      return {
        'success': true,
        'data': response['data'],
      };
    } else if (response is List) {
      return {
        'success': true,
        'data': response,
      };
    } else {
      // Format inattendu, retourner tel quel
      return {
        'success': true,
        'data': response,
      };
    }
  }
/*
  /// Récupère la liste de tous les utilisateurs.
  Future<List<Employe>> getUsers() async {
    final Map<String, dynamic> response = await _request('GET', '/api/employes');
    final List<dynamic> responseData = response['data'];
    return responseData.map((json) => Employe.fromJson(json)).toList();
  }
*/
  /// Crée une nouvelle convocation.
  Future<void> createConvocation(Convocation convocation) async {
    await _request(
      'POST',
      '/api/convocations',
      body: convocation.toJson(),
    );
  }
}
