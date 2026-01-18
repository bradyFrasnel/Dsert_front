import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dsertmobile/component/couleur.dart';
import 'package:dsertmobile/model/convocation.dart';
import 'package:dsertmobile/service/convocationService.dart';
import 'package:dsertmobile/controller/userController.dart';

class ConvocationDetailPage extends StatefulWidget {
  final Convocation convocation;
  
  const ConvocationDetailPage({
    super.key,
    required this.convocation,
  });

  @override
  State<ConvocationDetailPage> createState() => _ConvocationDetailPageState();
}

class _ConvocationDetailPageState extends State<ConvocationDetailPage> {
  late final ConvocationService _convocationService;
  late final UserController _userController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _convocationService = ConvocationService();
    _userController = Provider.of<UserController>(context, listen: false);
  }

  Future<void> _respondToConvocation(String response) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _convocationService.respondToConvocation(
        convocationId: widget.convocation.id!,
        response: response,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Réponse envoyée: $response'),
            backgroundColor: Couleur.succes,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Couleur.erreur,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

  bool _canRespond() {
    final estParticipant = widget.convocation.participants.any((p) => p.id == _userController.currentUser?.id);
    final estEmetteur = widget.convocation.emetteurId == _userController.currentUser?.id;
    final estPassee = widget.convocation.estPassee;
    
    return (estParticipant || estEmetteur) && !estPassee && widget.convocation.statut == ConvocationStatut.enAttente;
  }

  @override
  Widget build(BuildContext context) {
    final statutColor = _getStatutColor(widget.convocation.statut);
    final statutString = _getStatutString(widget.convocation.statut);
    final peutRepondre = _canRespond();

    return Scaffold(
      backgroundColor: Couleur.fond,
      appBar: AppBar(
        title: const Text(
          'Détails de la Convocation',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Couleur.principale,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte principale
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête avec statut
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.convocation.titre,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: statutColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statutString,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Description
                    if (widget.convocation.description.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Couleur.textePrincipal,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.convocation.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Couleur.texteSecondaire,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    
                    // Informations de date et lieu
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.calendar_today,
                            title: 'Date',
                            content: '${widget.convocation.dateFormatee} • ${widget.convocation.heureRange}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.location_on,
                            title: 'Lieu',
                            content: widget.convocation.lieu,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Participants
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Participants',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Couleur.textePrincipal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...widget.convocation.participants.map((participant) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Couleur.principale,
                                child: Text(
                                  participant.prenom?.isNotEmpty ?? false 
                                      ? participant.prenom![0].toUpperCase()
                                      : participant.nomFamille![0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${participant.prenom} ${participant.nomFamille}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      participant.email!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Couleur.texteSecondaire,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Boutons de réponse
                    if (peutRepondre)
                      Column(
                        children: [
                          const Text(
                            'Répondre à cette convocation',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Couleur.textePrincipal,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : () => _respondToConvocation('ACCEPTE'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Couleur.succes,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Text(
                                            'Accepter',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : () => _respondToConvocation('REFUSE'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Couleur.erreur,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Text(
                                            'Refuser',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Couleur.principale, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Couleur.texteSecondaire,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _convocationService.dispose();
    super.dispose();
  }
}
