/*

import 'package:dsertmobile/model/convocation.dart'; // Importer le bon modèle
import 'package:dsertmobile/model/employe.dart';
import 'package:dsertmobile/service/apiService.dart'; // Importer le service API
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConvocationPage extends StatefulWidget {
  const ConvocationPage({super.key});

  @override
  State<ConvocationPage> createState() => _ConvocationPageState();
}

class _ConvocationPageState extends State<ConvocationPage> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _lieuController = TextEditingController();
  final ApiService _apiService = ApiService(); // Instance du service

  // Nouveaux états pour gérer la date et les heures séparément
  DateTime? _selectedDate;
  TimeOfDay? _selectedHeureDebut;
  TimeOfDay? _selectedHeureFin;
  bool _isLoading = false; // Pour gérer l'état de chargement du bouton

  // Données simulées (vous les remplacerez par un appel API plus tard)
  final List<Employe> _listeEmployes = [
    Employe(id: '3e8e7a92-36fa-448c-9842-c4aeb6f90f73', nomFamille: 'Employe Un'),
    Employe(id: 'ae7ba4d9-4c2a-4edb-bda5-a39d83c3da16', nomFamille: 'Employe Deux'),
    Employe(id: 'b7e09542-edb5-4fbe-8b8b-5817800b0de6', nomFamille: 'Employe Trois'),
  ];

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _lieuController.dispose();
    super.dispose();
  }

  // --- Fonctions de sélection ---

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(bool isHeureDebut) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: (isHeureDebut ? _selectedHeureDebut : _selectedHeureFin) ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isHeureDebut) {
          _selectedHeureDebut = picked;
        } else {
          _selectedHeureFin = picked;
        }
      });
    }
  }
  
  Future<void> _envoyerConvocation() async {
    if (!_formKey.currentState!.validate()) return;

    final List<Employe> employesSelectionnes = _listeEmployes.where((e) => e.isSelected).toList();

    // Validations
    if (_selectedDate == null || _selectedHeureDebut == null || _selectedHeureFin == null) {
      _showErrorSnackBar('Veuillez sélectionner une date et les heures de début et de fin.');
      return;
    }
    if (employesSelectionnes.isEmpty) {
      _showErrorSnackBar('Veuillez sélectionner au moins un destinataire.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Combiner la date et l'heure de début pour créer l'objet DateTime complet
      final dateConvocation = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedHeureDebut!.hour,
        _selectedHeureDebut!.minute,
      );

      // Formater les heures au format "HH:mm" que le serveur attend
      final formatHeure = (TimeOfDay time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

      //Créer l'objet Convocation en utilisant notre modèle
      final nouvelleConvocation = Convocation(
        titre: _titreController.text,
        description: _descriptionController.text,
        lieu: _lieuController.text,
        dateConvocation: dateConvocation, // Le DateTime complet
        heureDebut: formatHeure(_selectedHeureDebut!), // String "HH:mm"
        heureFin: formatHeure(_selectedHeureFin!),   // String "HH:mm"
        participants: employesSelectionnes,
      );

      // 3. Appeler le service API pour envoyer les données
      //await _apiService.createConvocation(nouvelleConvocation);

      // Si tout s'est bien passé
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Convocation envoyée avec succès !'),
          backgroundColor: Color(0xFF388E3C),
        ),
      );
      Navigator.of(context).pop();

    } catch (e) {
      _showErrorSnackBar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  // --- BUILD METHOD MIS À JOUR ---

  @override
  Widget build(BuildContext context) {
    // Helper pour formater l'heure affichée dans l'UI
    final formatAffichageHeure = (TimeOfDay? time) => time?.format(context) ?? 'Sélectionner...';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Convocation'),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // ... (Champs Titre, Description restent les mêmes)
            TextFormField(
              controller: _titreController,
              decoration: const InputDecoration(labelText: 'Titre', border: OutlineInputBorder(), prefixIcon: Icon(Icons.title)),
              validator: (value) => value!.isEmpty ? 'Veuillez entrer un titre' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description (optionnel)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.description)),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Date et Heures'),
            // --- NOUVELLE SECTION DATE/HEURE ---
            _buildSelectorRow(
              'Date',
              Icons.calendar_today,
              _selectedDate == null ? 'Sélectionner...' : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                  () => _selectDate(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildSelectorRow('Début', Icons.access_time, formatAffichageHeure(_selectedHeureDebut), () => _selectTime(true))),
                const SizedBox(width: 16),
                Expanded(child: _buildSelectorRow('Fin', Icons.access_time_filled, formatAffichageHeure(_selectedHeureFin), () => _selectTime(false))),
              ],
            ),
            const SizedBox(height: 16),

            _buildSectionTitle('Lieu'),
            TextFormField(
              controller: _lieuController,
              decoration: const InputDecoration(labelText: 'Lieu', border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on)),
              validator: (value) => value!.isEmpty ? 'Veuillez entrer un lieu' : null,
            ),
            const SizedBox(height: 24),

            // ... (Liste des destinataires reste la même)
            _buildSectionTitle('Destinataires'),
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4.0)),
              height: 150, // Hauteur ajustée
              child: ListView.builder(
                itemCount: _listeEmployes.length,
                itemBuilder: (context, index) {
                  final employe = _listeEmployes[index];
                  return CheckboxListTile(
                    title: Text(employe.nomComplet ?? 'Employé ${employe.id}'), // Utilisation de l'opérateur null-check
                    value: employe.isSelected,
                    onChanged: (bool? value) => setState(() => employe.isSelected = value!),
                    activeColor: const Color(0xFF1976D2),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // Bouton d'envoi avec indicateur de chargement
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _envoyerConvocation,
              icon: const Icon(Icons.send),
              label: _isLoading ?
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2
              ) : const Text('ENVOYER',
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF0D47A1),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF757575),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSelectorRow(String label, IconData icon, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon, color: const Color(0xFF0D47A1)),
        ),
        child: Text(value),
      ),
    );
  }
}


 */