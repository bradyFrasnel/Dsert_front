import 'package:dsertmobile/view/convocationCreateAddParticipant.dart';
import 'package:flutter/material.dart';
import 'package:dsertmobile/component/couleur.dart';
import 'package:dsertmobile/model/employe.dart';
import 'package:dsertmobile/service/convocationService.dart';

class ConvocationCreatePage extends StatefulWidget {
  const ConvocationCreatePage({super.key});

  @override
  State<ConvocationCreatePage> createState() => _ConvocationCreatePageState();
}

class _ConvocationCreatePageState extends State<ConvocationCreatePage> {
  late final ConvocationService _convocationService;
  
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _lieuController = TextEditingController();
  final _dateController = TextEditingController();
  final _heureDebutController = TextEditingController();
  final _heureFinController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  List<Employe> _selectedParticipants = [];
  bool _avecChat = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _convocationService = ConvocationService();
    _dateController.text = _formatDate(_selectedDate);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _lieuController.dispose();
    _dateController.dispose();
    _heureDebutController.dispose();
    _heureFinController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'), // 🇫🇷 Localisation française
      helpText: 'Sélectionner une date',
      cancelText: 'Annuler',
      confirmText: 'Valider',
      fieldLabelText: 'Date de la convocation',
      fieldHintText: 'JJ/MM/AAAA',
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _selectTime(String controllerType) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Sélectionner une heure',
      cancelText: 'Annuler',
      confirmText: 'Valider',
      hourLabelText: 'Heure',
      minuteLabelText: 'Minute',
    );
    
    if (picked != null) {
      // Formatage sécurisé de l'heure
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      final time = '$hour:$minute';
      
      print('DEBUG: Heure sélectionnée: $time'); // Debug
      
      if (controllerType == 'debut') {
        _heureDebutController.text = time;
      } else {
        _heureFinController.text = time;
      }
    }
  }

  Future<void> _createConvocation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _convocationService.createConvocation(
        titre: _titreController.text,
        description: _descriptionController.text,
        dateConvocation: _selectedDate,
        heureDebut: _heureDebutController.text,
        heureFin: _heureFinController.text,
        lieu: _lieuController.text,
        participants: _selectedParticipants,
        avecChat: _avecChat,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Convocation créée avec succès'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Couleur.fond,
      appBar: AppBar(
        backgroundColor: Couleur.principale,
        foregroundColor: Colors.white,
        elevation: 4.0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],

        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 50.0,
              vertical: 15.0
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    //widget.user.prenom,
                    'D\'Sert,',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        toolbarHeight: kToolbarHeight + 50, // Hauteur de l'appBar.
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Titre
              TextFormField(
                controller: _titreController,
                decoration: InputDecoration(
                  labelText: 'Titre ',
                  prefixIcon: const Icon(Icons.title, color: Couleur.principale),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Couleur.principale),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Couleur.principale, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le titre est obligatoire';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Description',
                  prefixIcon: const Icon(Icons.description, color: Couleur.principale),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Couleur.principale),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Couleur.principale, width: 2),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Date
              GestureDetector(
                onTap: _selectDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dateController,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Date de convocation',
                      prefixIcon: const Icon(Icons.calendar_today, color: Couleur.principale,),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Couleur.principale),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Couleur.principale, width: 2),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Heures
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime('debut'),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _heureDebutController,
                          enabled: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez sélectionner une heure de début';
                            }
                            // Validation du format HH:MM (00:00 à 23:59)
                            if (!RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value)) {
                              return 'Format d\'heure invalide. Utilisez le format 24h (ex: 15:30)';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Heure de début',
                            prefixIcon: const Icon(Icons.access_time),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Couleur.principale),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Couleur.principale, width: 2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime('fin'),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _heureFinController,
                          enabled: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez sélectionner une heure de fin';
                            }
                            // Validation du format HH:MM (00:00 à 23:59)
                            if (!RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value)) {
                              return 'Format d\'heure invalide. Utilisez le format 24h (ex: 15:30)';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Heure de fin',
                            prefixIcon: const Icon(Icons.access_time),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Couleur.principale),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Couleur.principale, width: 2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Lieu
              TextFormField(
                controller: _lieuController,
                decoration: InputDecoration(
                  labelText: 'Lieu',
                  prefixIcon: const Icon(Icons.location_on, color: Couleur.avertissement),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Couleur.principale),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Couleur.principale, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lieu obligatoire';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Participants
              Text(
                'Participants',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Couleur.textePrincipal,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                child: TextButton(
                  child: const Text('Ajouter les participants', style: TextStyle(color: Couleur.principale)),
                  onPressed: () {
                    showDialog(context: context, builder: (context) => const AddParticipant());
                  }
                  ),
              ),
              const SizedBox(height: 16),
              
              const SizedBox(height: 32),
              
              // Bouton de création
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createConvocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Couleur.principale,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
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
                          'Envoyer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
