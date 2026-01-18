import 'dart:async';
import 'package:dsertmobile/model/convocation.dart';
import 'package:dsertmobile/model/employe.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ConvocationService {
  IO.Socket? _socket;
  bool _isInitialized = false;
  
  final StreamController<Convocation> _nouvelleConvocationController = StreamController<Convocation>.broadcast();
  final StreamController<Map<String, dynamic>> _reponseConvocationController = StreamController<Map<String, dynamic>>.broadcast();
  
  Stream<Convocation> get nouvelleConvocation => _nouvelleConvocationController.stream;
  Stream<Map<String, dynamic>> get reponseConvocation => _reponseConvocationController.stream;

  final List<Convocation> _convocations = [];
  final StreamController<List<Convocation>> _convocationsController = StreamController<List<Convocation>>.broadcast();
  Stream<List<Convocation>> get convocations => _convocationsController.stream;

  Future<void> initialize() async {
    if (!_isInitialized) {
      await _initializeSocket();
      _isInitialized = true;
    }
  }

  Future<void> _initializeSocket() async {
    try {
      final storage = FlutterSecureStorage();

      final token = await storage.read(key: 'jwt_token');
      //final token = await storage.read(key: 'access_token');
      

      if (token == null) {
        debugPrint('❌ Token JWT non trouvé - utilisateur non connecté');
        return;
      }

      debugPrint('🔑 Token JWT trouvé: ${token.substring(0, 20)}...');

      // Configuration du socket avec authentification
      // Essayer plusieurs méthodes : auth.token et query parameters
      _socket = IO.io('http://10.0.2.2:4000/chat', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
        'auth': {
          'token': token,
        },
        'query': {
          'token': token,
        },
        'extraHeaders': {
          'Authorization': 'Bearer $token',
        },
      });

      // Écouter les erreurs AVANT la connexion
      _socket?.on('error', (error) {
        debugPrint('❌ Erreur Socket: $error');
        if (error is Map && error['message'] == 'Échec de l\'authentification') {
          debugPrint('⚠️ Authentification échouée - Vérifier le format du token');
        }
      });

      _socket?.onConnect((_) {
        debugPrint('✅ Connecté au serveur de convocations avec authentification');
        _setupEventListeners();
      });

      _socket?.onDisconnect((_) {
        debugPrint('❌ Déconnecté du serveur de convocations');
      });

      _socket?.onConnectError((error) {
        debugPrint('❌ Erreur de connexion Socket: $error');
      });

    } catch (e) {
      debugPrint('❌ Erreur initialisation socket: $e');
    }
  }

  void _setupEventListeners() {
    _socket?.on('nouvelleConvocation', (data) {
      try {
        debugPrint('📨 Nouvelle convocation reçue: $data');
        
        if (data['type'] == 'convocation') {
          final convocation = Convocation.fromJson(data['data']);
          
          _convocations.insert(0, convocation);
          _convocationsController.add(_convocations);
          
          _nouvelleConvocationController.add(convocation);
          
          debugPrint('🔔 NOUVELLE CONVOCATION REÇUE !');
          debugPrint('DEBUG: Titre: ${convocation.titre}');
          debugPrint('DEBUG: ID: ${convocation.id}');
        }
      } catch (e) {
        debugPrint('❌ Erreur traitement nouvelle convocation: $e');
      }
    });

    _socket?.on('convocationResponse', (data) {
      try {
        debugPrint('📝 Réponse de convocation reçue: $data');
        
        if (data['type'] == 'reponse_convocation') {
          _updateConvocationStatut(data['convocationId'], data['response']);
          
          _reponseConvocationController.add(data);
        }
      } catch (e) {
        debugPrint('❌ Erreur traitement réponse convocation: $e');
      }
    });

    _socket?.on('convocationUpdated', (data) {
      try {
        debugPrint('🔄 Convocation mise à jour: $data');
        final convocation = Convocation.fromJson(data);
        _updateConvocation(convocation);
      } catch (e) {
        debugPrint('❌ Erreur mise à jour convocation: $e');
      }
    });
  }

  void _updateConvocationStatut(String convocationId, String response) {
    try {
      final index = _convocations.indexWhere((c) => c.id == convocationId);
      if (index != -1) {
        ConvocationStatut nouveauStatut;
        switch (response) {
          case 'ACCEPTE':
            nouveauStatut = ConvocationStatut.acceptee;
            break;
          case 'REFUSE':
            nouveauStatut = ConvocationStatut.refusee;
            break;
          case 'ANNULE':
            nouveauStatut = ConvocationStatut.annulee;
            break;
          default:
            nouveauStatut = ConvocationStatut.enAttente;
        }

        _convocations[index] = _convocations[index].copyWith(statut: nouveauStatut);
        _convocationsController.add(_convocations);
      }
    } catch (e) {
      debugPrint('❌ Erreur mise à jour statut: $e');
    }
  }

  void _updateConvocation(Convocation convocation) {
    try {
      final index = _convocations.indexWhere((c) => c.id == convocation.id);
      if (index != -1) {
        _convocations[index] = convocation;
        _convocationsController.add(_convocations);
      } else {
        _convocations.insert(0, convocation);
        _convocationsController.add(_convocations);
      }
    } catch (e) {
      debugPrint('❌ Erreur mise à jour convocation: $e');
    }
  }

  List<Convocation> getConvocationsPourUtilisateur(String utilisateurId) {
    return _convocations.where((convocation) {
      return convocation.participants.any((p) => p.id == utilisateurId) ||
             convocation.emetteurId == utilisateurId;
    }).toList();
  }

  List<Convocation> getConvocationsParStatut(ConvocationStatut statut) {
    return _convocations.where((c) => c.statut == statut).toList();
  }

  void initializeConvocations(List<Convocation> convocations) {
    _convocations.clear();
    _convocations.addAll(convocations);
    _convocationsController.add(_convocations);
    debugPrint('📋 ${convocations.length} convocations initialisées');
  }

  Future<void> createConvocation({
    required String titre,
    required String description,
    required DateTime dateConvocation,
    required String heureDebut,
    required String heureFin,
    required String lieu,
    required List<Employe> participants,
    bool avecChat = false,
  }) async {
    try {
      if (_socket?.connected != true) {
        debugPrint('❌ Socket non connecté');
        return;
      }

      final convocationData = {
        'titre': titre,
        'description': description,
        'date_convocation': dateConvocation.toIso8601String(),
        'heure_debut': heureDebut,
        'heure_fin': heureFin,
        'lieu': lieu,
        'participants': participants.map((p) => p.toJson()).toList(),
        'avecChat': avecChat,
      };

      debugPrint('📤 Création convocation: $convocationData');
      _socket?.emit('createConvocation', convocationData);
      
    } catch (e) {
      debugPrint('❌ Erreur création convocation: $e');
    }
  }

  Future<void> respondToConvocation({
    required String convocationId,
    required String response,
  }) async {
    try {
      if (_socket?.connected != true) {
        debugPrint('❌ Socket non connecté');
        return;
      }

      final responseData = {
        'convocationId': convocationId,
        'response': response,
      };

      debugPrint('📤 Réponse convocation: $responseData');
      _socket?.emit('respondToConvocation', responseData);
      
    } catch (e) {
      debugPrint('❌ Erreur réponse convocation: $e');
    }
  }

  bool get isConnected => _socket?.connected ?? false;

  void dispose() {
    _nouvelleConvocationController.close();
    _reponseConvocationController.close();
    _convocationsController.close();
    
    if (_socket?.connected == true) {
      _socket?.disconnect();
    }
  }
}
