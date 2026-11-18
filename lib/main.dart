import 'package:material_ui/material_ui.dart';

import 'theme/beadaries_theme.dart';
import 'screens/customer_reservation_screen.dart';
import 'screens/admin_reservation_approval_screen.dart';

void main() {
  runApp(const BeadariesApp());
}

class BeadariesApp extends StatelessWidget {
  const BeadariesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beadaries',
      debugShowCheckedModeBanner: false,
      theme: BeadariesTheme.themeData,
      home: const ReservationDemoSwitcher(),
    );
  }
}

class ReservationDemoSwitcher extends StatefulWidget {
  const ReservationDemoSwitcher({super.key});

  @override
  State<ReservationDemoSwitcher> createState() =>
      _ReservationDemoSwitcherState();
}

class _ReservationDemoSwitcherState extends State<ReservationDemoSwitcher> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    CustomerReservationScreen(),
    AdminReservationApprovalScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Customer (FR-04/05/06)',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings),
            label: 'Admin (FR-07)',
          ),
        ],
      ),
    );
  }
}
