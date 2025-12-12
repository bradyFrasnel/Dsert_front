import 'package:flutter/material.dart';

class Dashbordemploye extends StatefulWidget {
  const Dashbordemploye({super.key});

  @override
  State<Dashbordemploye> createState() => _DashbordemployeState();
}

class _DashbordemployeState extends State<Dashbordemploye> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Dashbord Employe")),
      ),
    );
  }
}
