import 'package:material_ui/material_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../theme/app_theme.dart';
import '../auth/auth_screen.dart';
import 'ai_recommender_screen.dart';
import 'catalogue_screen.dart';
import '../customer_reservation_screen.dart';
import '../../models/ai_recommendation.dart';
import '../../services/reservation_store.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _selectedIndex = 0;
  BeadProduct? _preselectedProduct;
  String? _designNotes;

  void _useDesign(AiRecommendation result) {
    final matches = result.matchedProducts;
    setState(() {
      _preselectedProduct = matches.isEmpty ? null : matches.first;
      _designNotes = result.designSummary;
      _selectedIndex = 2;
    });
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        title: const Text(
          'beadaries',
          style: TextStyle(color: AppColors.sage, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.sage),
            tooltip: 'Sign Out',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          AiRecommenderScreen(onUseInReservation: _useDesign),
          const CatalogueScreen(),
          CustomerReservationScreen(
            key: ValueKey(
              '${_preselectedProduct?.id ?? 'none'}-${_designNotes ?? ''}',
            ),
            preselectedProduct: _preselectedProduct,
            initialCustomNotes: _designNotes,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'AI Stylist',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Catalogue',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Reservations',
          ),
        ],
      ),
    );
  }
}
