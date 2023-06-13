import 'package:flutter/material.dart';
import 'package:menu_teste/widgets/auth_check.dart';

class appisqrac extends StatelessWidget {
  const appisqrac({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Infordocente',
      
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber
      ),
      home: AuthCheck(),
    );
  }
}