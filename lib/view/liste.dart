import 'package:dsertmobile/component/couleur.dart';
import 'package:dsertmobile/model/employe.dart';
import 'package:dsertmobile/service/apiService.dart';
import 'package:flutter/material.dart';
import 'package:dsertmobile/component/userFlipCard.dart';

class ListePage extends StatefulWidget {
  const ListePage({super.key});

  @override
  State<ListePage> createState() => _ListePageState();
}

class _ListePageState extends State<ListePage> {
  final TextEditingController _searchController = TextEditingController();
  late Future<Map<String, dynamic>> _futureEmployes;
  List<Employe> _tousLesEmployes = [];
  List<Employe> _employesAffiches = [];
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filtrerEmployes);
    _chargerDonneesInitiales();
  }

  void _chargerDonneesInitiales() {
    _futureEmployes = _apiService.getUsers();
    _futureEmployes.then((response) {
      try {
        List<dynamic> data = [];
        
        if (response['success'] == true && response['data'] != null) {
          data = response['data'] as List<dynamic>;
        } else if (response['data'] != null) {
          // Format sans 'success'
          data = response['data'] as List<dynamic>;
        }
        
        if (data.isNotEmpty) {
          final List<Employe> liste = data.map((item) {
            try {
              return Employe.fromJson(item as Map<String, dynamic>);
            } catch (e) {
              print('Erreur parsing employé: $e');
              print('Données: $item');
              rethrow;
            }
          }).toList();
          
          if (mounted) {
            setState(() {
              _tousLesEmployes = liste;
              _employesAffiches = liste;
            });
          }
        }
      } catch (e) {
        print('Erreur traitement données employés: $e');
        print('Réponse API: $response');
      }
    }).catchError((error) {
      print('Erreur chargement employés: $error');
      if (mounted) {
        setState(() {
          // S'assurer que _isLoading est désactivé
        });
      }
    });
  }

  void _filtrerEmployes() {
    final requete = _searchController.text.toLowerCase();
    setState(() {
      _employesAffiches = _tousLesEmployes.where((employe) {
        return employe.nomComplet.toLowerCase().contains(requete) ||
            (employe.email?.toLowerCase().contains(requete) ?? false);
      }).toList();
    });
  }

  Future<void> _refreshUsers() async {
    try {
      final response = await _apiService.getUsers();
      List<dynamic> data = [];
      
      if (response['success'] == true && response['data'] != null) {
        data = response['data'] as List<dynamic>;
      } else if (response['data'] != null) {
        // Format sans 'success'
        data = response['data'] as List<dynamic>;
      }
      
      if (data.isNotEmpty) {
        final List<Employe> liste = data.map((item) => Employe.fromJson(item)).toList();
        setState(() {
          _searchController.clear();
          _tousLesEmployes = liste;
          _employesAffiches = liste;
          _futureEmployes = Future.value(response);
        });
      }
    } catch (e) {
      print('Erreur rafraîchissement employés: $e');
    }
  }

  void _showUserDetailsDialog(BuildContext context, Employe user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(user.nomComplet),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Email: ${user.email ?? 'Non fourni'}'),
                Text('Rôle: ${user.role ?? 'Non défini'}'),
                Text('Date d\'embauche: ${user.dateEmbauche?.toLocal().toString().split(' ')[0] ?? 'N/A'}'),
                Text('Statut: ${user.actif == true ? 'Actif' : 'Inactif'}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserCard(Employe user) {
    return UserFlipCard(
      user: user,
      onShowDetails: () {
        _showUserDetailsDialog(context, user);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureEmployes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              ],
            );
          }

          if (snapshot.hasError) {
            return CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Erreur: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _chargerDonneesInitiales();
                            });
                          },
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                const SliverFillRemaining(child: Center(child: Text('Aucune donnée disponible.'))),
              ],
            );
          }

          // Traiter les données directement depuis la snapshot
          final response = snapshot.data!;
          List<dynamic> data = [];
          
          try {
            if (response['success'] == true && response['data'] != null) {
              data = response['data'] as List<dynamic>;
            } else if (response['data'] != null) {
              data = response['data'] as List<dynamic>;
            }
            
            if (data.isEmpty) {
              return CustomScrollView(
                slivers: [
                  _buildSliverAppBar(),
                  const SliverFillRemaining(child: Center(child: Text('Aucun utilisateur trouvé.'))),
                ],
              );
            }
            
            // Parser les données
            final List<Employe> liste = data.map((item) {
              try {
                return Employe.fromJson(item as Map<String, dynamic>);
              } catch (e) {
                print('Erreur parsing employé: $e');
                return null;
              }
            }).whereType<Employe>().toList();
            
            // Mettre à jour les listes si nécessaire (pour la recherche)
            if (_tousLesEmployes.length != liste.length) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _tousLesEmployes = liste;
                    // Appliquer le filtre de recherche si actif
                    _filtrerEmployes();
                  });
                }
              });
            }
            
            // Utiliser _employesAffiches pour la recherche, sinon la liste complète
            final List<Employe> employesAAfficher = _employesAffiches.isNotEmpty 
                ? _employesAffiches 
                : liste;
            
            return RefreshIndicator(
              onRefresh: _refreshUsers,
              child: CustomScrollView(
                slivers: [
                  _buildSliverAppBar(),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= employesAAfficher.length) {
                          return const SizedBox.shrink();
                        }
                        return _buildUserCard(employesAAfficher[index]);
                      },
                      childCount: employesAAfficher.length,
                    ),
                  ),
                ],
              ),
            );
          } catch (e) {
            print('Erreur affichage liste: $e');
            return CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Erreur: $e'),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Couleur.principale,
      foregroundColor: Colors.white,
      pinned: true,
      expandedHeight: 140.0,
      title: const Text('Utilisateurs'),
      actions: [
        IconButton(icon: const Icon(Icons.person_add_alt_1_outlined), tooltip: 'Ajouter', onPressed: () {}),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher un employé...',
              hintStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
