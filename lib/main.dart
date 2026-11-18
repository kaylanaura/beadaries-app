import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/auth/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BeadariesApp());
}

class BeadariesApp extends StatelessWidget {
  const BeadariesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beadaries',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthScreen(),
    );
  }
}
