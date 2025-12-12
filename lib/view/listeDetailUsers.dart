import 'package:dsertmobile/model/employe.dart';
import 'package:flutter/material.dart';


class ListeDetailUser extends StatelessWidget {
  final Employe user;
  const ListeDetailUser({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('AlertDialog Title'),
      content: const SingleChildScrollView(
        child: ListBody(
          children: <Widget>[

          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text(''),
          onPressed: () {

          },
        ),
      ],
    );
  }
}
