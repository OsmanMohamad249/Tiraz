// mobile-app/lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/presentation/splash_screen.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize secure storage options for web if needed
    // Note: flutter_secure_storage usually handles this, but explicit options can help
    // const FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));

    runApp(
      ProviderScope(
        child: QeyafaApp(),
      ),
    );
  }, (error, stack) {
    print('Caught Dart Error: $error');
    print(stack);
  });
}

class QeyafaApp extends StatelessWidget {
  const QeyafaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qeyafa',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
