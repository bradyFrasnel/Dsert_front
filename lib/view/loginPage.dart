// lib/view/loginPage.dart

import 'package:dsertmobile/component/couleur.dart';
import 'package:dsertmobile/mainScaffold.dart';
import 'package:dsertmobile/model/employe.dart';
import 'package:dsertmobile/service/apiService.dart';
import 'package:dsertmobile/view/register.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dsertmobile/controller/userController.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Instance de notre service API
  final ApiService _apiService = ApiService();

  // Pour gérer la visibilité du mot de passe
  bool _isPasswordVisible = false;

  // Méthode pour gérer la soumission du formulaire
  Future<void> _handleLogin() async {
    // Si le formulaire n'est pas valide, on ne fait rien
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Affiche le cercle de chargement
    setState(() {
      _isLoading = true;
    });

    try {
      // Appel à votre ApiService pour la connexion
      final result = await _apiService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Si le login est réussi (vérifié dans ApiService) et que le widget est toujours affiché
      if (result['success'] == true && mounted) {
        // On récupère les infos de l'utilisateur avec la clé 'user'
        final Employe user = Employe.fromJson(result['user']);

        // Stocker l'utilisateur dans le UserController
        final userController = Provider.of<UserController>(context, listen: false);
        userController.setUtilisateur(user);

        // On navigue vers la page principale et on supprime toutes les routes précédentes
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainScaffold(user: user),
          ),
        );
      }
    } catch (e) {
      // Si une erreur se produit, on l'affiche dans un SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Quoi qu'il arrive, on cache le cercle de chargement
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.lock_outline_sharp,
                  size: 80,
                  color: Couleur.principale,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Welcome to D\'Sert !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Couleur.principale,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Your business application',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Couleur.texteSecondaire
                  ),
                ),
                Text(
                  'Login to continue 🍀',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Couleur.texteSecondaire,
                  ),
                ),
                const SizedBox(height: 40),

                // Formulaire de connexion
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Champ pour l'email
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Couleur.principale,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre email';
                          }
                          if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                            return 'Veuillez entrer un email valide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Champ pour le mot de passe
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Couleur.principale,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Couleur.principale,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre mot de passe';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Bouton de connexion
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Couleur.principale,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'CONNEXION',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Je n\'est pas de compte.'),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterPage()) );
                      },
                      child: Text(
                        'Iscription !!',
                        style: TextStyle(
                          color: Couleur.secondaire
                        ),
                      ),
                    )
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
