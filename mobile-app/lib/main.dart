// mobile-app/lib/main.dart
import 'package:flutter/material.dart';

void main() {
  runApp(TirazApp());
}

class TirazApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tiraz (Flutter Boilerplate)',
      home: Scaffold(
        appBar: AppBar(title: Text('Tiraz - Home')),
        body: Center(child: Text('Welcome to Tiraz Flutter app (boilerplate)')),
      ),
    );
  }
}
