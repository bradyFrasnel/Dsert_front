import 'package:dsertmobile/animation.dart';
import 'package:dsertmobile/component/couleur.dart';
import 'package:dsertmobile/controller/userController.dart';
import 'package:dsertmobile/mainScaffold.dart';
import 'package:dsertmobile/view/accueil.dart';
import 'package:dsertmobile/view/loginPage.dart';
import 'package:dsertmobile/view/register.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserController()),
      ],
      child: const MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'D\'Sert Mobile',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto'
      ),
      debugShowCheckedModeBanner: false,
      // Configuration de la localisation française
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'), // Français
        Locale('en', 'US'), // Anglais (optionnel)
      ],
      locale: const Locale('fr', 'FR'), // Langue par défaut : Français
      //home: RegisterPage(),
      //home: LoginPage(),
      home: Scaffold(
        backgroundColor: Couleur.secondaire,
        body: Center(
          child: AnimatedLogo(size: 400),
        ),
      ),
      // Suppression du logo Flutter par défaut
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            // Supprime le logo Flutter en haut à gauche
            padding: EdgeInsets.zero,
          ),
          child: child!,
        );
      },
    );
  }
}
