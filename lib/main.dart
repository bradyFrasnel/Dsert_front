import 'package:dsertmobile/controller/userController.dart';
import 'package:dsertmobile/mainScaffold.dart';
import 'package:dsertmobile/view/accueil.dart';
import 'package:dsertmobile/view/loginPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      //home: MainScaffold(),
      home: LoginPage(),
    );
  }
}
