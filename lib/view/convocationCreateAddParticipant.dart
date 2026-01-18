import 'package:dsertmobile/component/couleur.dart';
import 'package:dsertmobile/model/employe.dart';
import 'package:dsertmobile/service/apiService.dart';
import 'package:flutter/material.dart';

class AddParticipant extends StatefulWidget {
  const AddParticipant({super.key});

  @override
  State<AddParticipant> createState() => _AddParticipantState();
}

class _AddParticipantState extends State<AddParticipant> {
  List<Employe> _tousLesEmployes = [];
  List<Employe> _selectedParticipants = [];
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadEmployes();
  }

  Future<void> _loadEmployes() async {
    try {
      final response = await _apiService.getUsers();
      
      // Gérer différents formats de réponse
      List<dynamic> data = [];
      
      if (response['success'] == true && response['data'] != null) {
        data = response['data'] as List<dynamic>;
      } else if (response['data'] != null) {
        // Format sans 'success'
        data = response['data'] as List<dynamic>;
      }
      
      if (data.isNotEmpty) {
        setState(() {
          _tousLesEmployes = data.map((item) => Employe.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('Aucun employé trouvé dans la réponse');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Erreur chargement employés: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Couleur.fond,
      title: Row(
        children: [
          Icon(Icons.people, color: Couleur.principale),
          const SizedBox(width: 8),
          const Text(
            'Sélectionner les participants',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Couleur.textePrincipal,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Barre de recherche
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Rechercher un employé...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Couleur.principale),
                      ),
                    ),
                    onChanged: (String? value) {
                      // TODO: Implémenter la recherche
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Liste des employés
                  Expanded(
                    child: ListView.builder(
                      itemCount: _tousLesEmployes.length,
                      itemBuilder: (context, index) {
                        final employe = _tousLesEmployes[index];
                        final isSelected = _selectedParticipants.contains(employe);
                        
                        return CheckboxListTile(
                          title: Text(
                            '${employe.prenom} ${employe.nomFamille}',
                            style: TextStyle(
                              color: isSelected ? Couleur.principale : Couleur.textePrincipal,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            employe.email!,
                            style: TextStyle(
                              color: Couleur.texteSecondaire,
                              fontSize: 12,
                            ),
                          ),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedParticipants.add(employe);
                              } else {
                                _selectedParticipants.remove(employe);
                              }
                            });
                          },
                          activeColor: Couleur.principale,
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_selectedParticipants);
          },
          child: Text(
            'Valider (${_selectedParticipants.length})',
            style: TextStyle(
              color: Couleur.principale,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          child: const Text(
            'Annuler',
            style: TextStyle(color: Couleur.texteSecondaire),
          ),
        ),
      ],
    );
  }
}
