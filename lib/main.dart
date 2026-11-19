import 'package:material_ui/material_ui.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/auth/auth_screen.dart';

import 'package:provider/provider.dart';

import 'providers/admin_product_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const BeadariesApp());
}

class BeadariesApp extends StatelessWidget {
  const BeadariesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminProductProvider(),
      child: MaterialApp(
        title: 'Beadaries',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AuthScreen(),
      ),
    );
  }
}
