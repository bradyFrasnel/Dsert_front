import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dsertmobile/component/couleur.dart';
import 'package:dsertmobile/model/convocation.dart';
import 'package:dsertmobile/service/convocationService.dart';
import 'package:dsertmobile/controller/userController.dart';
import 'package:dsertmobile/view/convocationCreate.dart';
import 'package:dsertmobile/view/convocationDetail.dart';

class ConvocationListePage extends StatefulWidget {
  const ConvocationListePage({super.key});

  @override
  State<ConvocationListePage> createState() => _ConvocationListePageState();
}

class _ConvocationListePageState extends State<ConvocationListePage> {
  late final ConvocationService _convocationService;
  late final UserController _userController;
  List<Convocation> _convocations = [];
  String _filtreStatut = 'Toutes';

  @override
  void initState() {
    super.initState();
    _convocationService = ConvocationService();
    _userController = Provider.of<UserController>(context, listen: false);
    
    // Initialiser le service APRÈS avoir configuré l'utilisateur
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _convocationService.initialize();
    });
    
    _initializeListeners();
  }

  void _initializeListeners() {
    // Écouter les nouvelles convocations
    _convocationService.nouvelleConvocation.listen((convocation) {
      print('DEBUG: 🔔 NOUVELLE CONVOCATION REÇUE !');
      print('DEBUG: Titre: ${convocation.titre}');
      print('DEBUG: ID: ${convocation.id}');
      setState(() {});
      _showNotificationSnackBar(convocation);
    });

    // Écouter les réponses
    _convocationService.reponseConvocation.listen((response) {
      setState(() {});
      _showResponseSnackBar(response);
    });

    // Écouter les mises à jour
    _convocationService.convocations.listen((convocations) {
      setState(() {
        _convocations = convocations;
      });
    });
  }

  void _showNotificationSnackBar(Convocation convocation) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Nouvelle convocation: ${convocation.titre}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Couleur.principale,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Voir',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConvocationDetailPage(convocation: convocation),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showResponseSnackBar(Map<String, dynamic> response) {
    String message;
    Color backgroundColor;
    
    switch (response['response']) {
      case 'ACCEPTE':
        message = 'Convocation acceptée';
        backgroundColor = Couleur.succes;
        break;
      case 'REFUSE':
        message = 'Convocation refusée';
        backgroundColor = Couleur.erreur;
        break;
      case 'ANNULE':
        message = 'Convocation annulée';
        backgroundColor = Couleur.avertissement;
        break;
      default:
        message = 'Réponse enregistrée';
        backgroundColor = Couleur.secondaire;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  List<Convocation> get _filteredConvocations {
    if (_filtreStatut == 'Toutes') {
      return _convocations;
    } else {
      final statut = _getStatutFromString(_filtreStatut);
      return _convocations.where((c) => c.statut == statut).toList();
    }
  }

  ConvocationStatut _getStatutFromString(String statutString) {
    switch (statutString) {
      case 'En attente':
        return ConvocationStatut.enAttente;
      case 'Acceptée':
        return ConvocationStatut.acceptee;
      case 'Refusée':
        return ConvocationStatut.refusee;
      case 'Annulée':
        return ConvocationStatut.annulee;
      default:
        return ConvocationStatut.enAttente;
    }
  }

  String _getStatutString(ConvocationStatut statut) {
    switch (statut) {
      case ConvocationStatut.enAttente:
        return 'En attente';
      case ConvocationStatut.acceptee:
        return 'Acceptée';
      case ConvocationStatut.refusee:
        return 'Refusée';
      case ConvocationStatut.annulee:
        return 'Annulée';
    }
  }

  Color _getStatutColor(ConvocationStatut statut) {
    switch (statut) {
      case ConvocationStatut.enAttente:
        return Colors.orange;
      case ConvocationStatut.acceptee:
        return Couleur.succes;
      case ConvocationStatut.refusee:
        return Couleur.erreur;
      case ConvocationStatut.annulee:
        return Couleur.avertissement;
    }
  }

  @override
  Widget build(BuildContext context) {
    final utilisateur = _userController.utilisateur;
    final estManager = utilisateur?.role?.toUpperCase() == 'MANAGER' || utilisateur?.role?.toUpperCase() == 'ADMIN';
    final mesConvocations = _convocationService.getConvocationsPourUtilisateur(utilisateur?.id ?? '');

    // Debug pour vérifier les valeurs
    print('DEBUG: utilisateur = $utilisateur');
    print('DEBUG: estManager = $estManager');
    print('DEBUG: utilisateur.role = ${utilisateur?.role}');

    return Scaffold(
      backgroundColor: Couleur.fond,
      appBar: AppBar(
        title: const Center(child: Text(
          'Nouvelle mission 🥷🏾',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),),
        backgroundColor: Couleur.principale,
        elevation: 80,
        actions: [
          if (estManager)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'create') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ConvocationCreatePage(),
                    ),
                  );
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'create',
                    child: Row(
                      children: [
                        Icon(Icons.add, color: Couleur.principale, size: 20),
                        const SizedBox(width: 12),
                        const Text('Créer une convocation'),
                      ],
                    ),
                  ),
                ];
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Icon(Icons.filter_list, color: Couleur.principale),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    value: _filtreStatut,
                    isExpanded: true,
                    underline: Container(),
                    items: [
                      'Toutes',
                      'En attente',
                      'Acceptée',
                      'Refusée',
                      'Annulée',
                    ].map((statut) {
                      return DropdownMenuItem<String>(
                        value: statut,
                        child: Text(statut),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _filtreStatut = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Liste des convocations
          Expanded(
            child: mesConvocations.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredConvocations.length,
                    itemBuilder: (context, index) {
                      final convocation = _filteredConvocations[index];
                      return _buildConvocationCard(convocation);
                    },
                  ),
          ),
        ],
      ),
      // Bouton flottant pour créer (managers uniquement)
      floatingActionButton: estManager
          ? FloatingActionButton(
              onPressed: () {
                print('DEBUG: Bouton flottant cliqué');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConvocationCreatePage(),
                  ),
                );
              },
              backgroundColor: Couleur.principale,
              child: const Icon(Icons.send, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 80,
            color: Couleur.texteSecondaire,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune convocation',
            style: TextStyle(
              fontSize: 18,
              color: Couleur.texteSecondaire,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          if (_userController.utilisateur?.role == 'manager')
            Text(
              'Créez votre première convocation',
              style: TextStyle(
                fontSize: 14,
                color: Couleur.texteSecondaire,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConvocationCard(Convocation convocation) {
    final statutColor = _getStatutColor(convocation.statut);
    final statutString = _getStatutString(convocation.statut);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConvocationDetailPage(convocation: convocation),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec titre et statut
              Row(
                children: [
                  Expanded(
                    child: Text(
                      convocation.titre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statutColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statutString,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Date et heure
              Row(
                children: [
                  Icon(Icons.calendar_today, 
                       size: 18, 
                       color: Couleur.texteSecondaire),
                  const SizedBox(width: 8),
                  Text(
                    '${convocation.dateFormatee} • ${convocation.heureRange}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Couleur.texteSecondaire,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Lieu
              Row(
                children: [
                  Icon(Icons.location_on, 
                       size: 18, 
                       color: Couleur.texteSecondaire),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      convocation.lieu,
                      style: TextStyle(
                        fontSize: 14,
                        color: Couleur.texteSecondaire,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Participants
              Row(
                children: [
                  Icon(Icons.people, 
                       size: 18, 
                       color: Couleur.texteSecondaire),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${convocation.participants.length} participant(s)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Couleur.texteSecondaire,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _convocationService.dispose();
    super.dispose();
  }
}
