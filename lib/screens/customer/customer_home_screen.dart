import 'package:material_ui/material_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../theme/app_theme.dart';
import '../auth/auth_screen.dart';
import 'catalogue_screen.dart';

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
      _selectedIndex = 1;
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
          CustomerReservationScreen(
            key: ValueKey(
              '${_preselectedProduct?.id ?? 'none'}-${_designNotes ?? ''}',
            ),
            const SizedBox(height: 6),
            const Text(
              'Explore custom bead accessories & handmade pieces.',
              style: TextStyle(fontSize: 14, color: AppColors.muted),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CatalogueScreen()),
                  );
                },
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Explore Catalogue'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sage,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
