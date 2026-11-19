// Covers UI-04 Customer Reservation Form FR-04 + FR-05 Atomic Lock + UI-05 Track Status FR-06

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../services/reservation_store.dart';
import '../theme/beadaries_theme.dart';

class CustomerReservationScreen extends StatefulWidget {
  final BeadProduct? preselectedProduct;

  const CustomerReservationScreen({super.key, this.preselectedProduct});

  @override
  State<CustomerReservationScreen> createState() =>
      _CustomerReservationScreenState();
}

class _CustomerReservationScreenState extends State<CustomerReservationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _store = ReservationStore.instance;

  BeadProduct? _selectedProduct;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _trackIdController = TextEditingController(text: 'BDR-2026-1042');

  String _fulfillmentMethod = 'Campus Pickup';
  bool _isSubmitting = false;
  ReservationModel? _confirmedReservation;
  ReservationModel? _trackedReservation;
  String? _trackError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedProduct =
        widget.preselectedProduct ??
        _store.products.firstWhere(
          (p) => p.status == 'Available',
          orElse: () => _store.products.first,
        );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _trackIdController.dispose();
    super.dispose();
  }

  Future<void> _handleReserve() async {
    if (!_formKey.currentState!.validate() || _selectedProduct == null) return;

    setState(() => _isSubmitting = true);
    try {
      final result = await _store.submitReservation(
        productId: _selectedProduct!.id,
        customerName: _nameController.text,
        customerPhone: _phoneController.text,
        fulfillmentMethod: _fulfillmentMethod,
        customNotes: _notesController.text,
      );

      setState(() {
        _confirmedReservation = result;
        _trackIdController.text = result.referenceId;
        _nameController.clear();
        _phoneController.clear();
        _notesController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _handleTrack() {
    final query = _trackIdController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _trackError = 'Please enter a Reservation Reference ID.';
        _trackedReservation = null;
      });
      return;
    }

    final found = _store.findByReferenceId(query);
    setState(() {
      if (found == null) {
        _trackError =
            'Reservation ID not found. Please verify your code and try again.';
        _trackedReservation = null;
      } else {
        _trackError = null;
        _trackedReservation = found;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Reservations'),
            bottom: TabBar(
              controller: _tabController,
              labelColor: BeadariesTheme.purpleHint,
              unselectedLabelColor: BeadariesTheme.textMuted,
              indicatorColor: BeadariesTheme.purpleHint,
              tabs: const [
                Tab(
                  icon: Icon(Icons.shopping_bag_outlined),
                  text: 'Reserve (FR-04)',
                ),
                Tab(
                  icon: Icon(Icons.track_changes_outlined),
                  text: 'Track Status (FR-06)',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [_buildReserveFormTab(), _buildTrackStatusTab()],
          ),
        );
      },
    );
  }

  Widget _buildReserveFormTab() {
    if (_confirmedReservation != null) {
      final res = _confirmedReservation!;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          color: BeadariesTheme.creamCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: BeadariesTheme.sageGreen, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: BeadariesTheme.sageLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: BeadariesTheme.sageGreen,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Reservation Submitted!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Item is now locked as Pending (FR-05) while Aryanna reviews your request.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: BeadariesTheme.textMuted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: BeadariesTheme.purpleLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reference ID',
                            style: TextStyle(
                              fontSize: 11,
                              color: BeadariesTheme.textMuted,
                            ),
                          ),
                          Text(
                            res.referenceId,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: BeadariesTheme.purpleHint,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        tooltip: 'Copy ID',
                        icon: const Icon(
                          Icons.copy,
                          color: BeadariesTheme.purpleHint,
                        ),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: res.referenceId),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reference ID copied!'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 28),
                _summaryRow('Accessory', res.productName),
                _summaryRow('Price', 'RM ${res.priceMYR.toStringAsFixed(2)}'),
                _summaryRow('Fulfillment', res.fulfillmentMethod),
                _summaryRow('Status', res.status),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _confirmedReservation = null);
                      _tabController.animateTo(1);
                      _handleTrack();
                    },
                    child: const Text('Track My Reservation'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Handmade Piece',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<BeadProduct>(
              initialValue: _selectedProduct,
              isExpanded: true,
              items: _store.products.map((product) {
                final isAvail = product.status == 'Available';
                return DropdownMenuItem(
                  value: product,
                  child: Text(
                    '${product.name} (RM ${product.priceMYR.toStringAsFixed(2)}) — ${product.status}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isAvail
                          ? BeadariesTheme.textDark
                          : BeadariesTheme.textMuted,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedProduct = val),
            ),
            if (_selectedProduct != null &&
                _selectedProduct!.status != 'Available')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        color: Colors.deepOrange,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'One-of-one item locked (${_selectedProduct!.status}). Choose an Available piece.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'Full Name *',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'e.g., Nurul Izzah'),
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Full name is required'
                  : null,
            ),
            const SizedBox(height: 16),
            const Text(
              'Phone Number / Email *',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                hintText: 'e.g., 012-3456789 or name@email.com',
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Phone number or email is required';
                }
                final v = val.trim();
                final isPhone = RegExp(r'^01[0-9]-?[0-9]{7,8}$').hasMatch(v);
                final isEmail = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v);
                if (!isPhone && !isEmail) {
                  return 'Enter a valid Malaysian phone (01X-XXXXXXX) or email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Fulfillment Preference *',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'Campus Pickup',
                  icon: Icon(Icons.school_outlined),
                  label: Text('Campus Pickup'),
                ),
                ButtonSegment(
                  value: 'Postage',
                  icon: Icon(Icons.local_shipping_outlined),
                  label: Text('Postage'),
                ),
              ],
              selected: {_fulfillmentMethod},
              onSelectionChanged: (set) =>
                  setState(() => _fulfillmentMethod = set.first),
            ),
            const SizedBox(height: 16),
            const Text(
              'Optional Customization / AI Design Notes',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText:
                    'Wrist size (cm), charm note, or AI design suggestion...',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    (_isSubmitting ||
                        _selectedProduct == null ||
                        _selectedProduct!.status != 'Available')
                    ? null
                    : _handleReserve,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(
                  _isSubmitting ? 'Locking Piece...' : 'Confirm Reservation',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackStatusTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter Reservation Reference ID',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _trackIdController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(hintText: 'BDR-2026-XXXX'),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _handleTrack,
                child: const Text('Check'),
              ),
            ],
          ),
          if (_trackError != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _trackError!,
                style: TextStyle(color: Colors.red.shade800, fontSize: 13),
              ),
            ),
          ],
          if (_trackedReservation != null) ...[
            const SizedBox(height: 18),
            _buildStatusCard(_trackedReservation!),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard(ReservationModel res) {
    Color badgeBg;
    Color badgeFg;
    if (res.status == 'Approved') {
      badgeBg = BeadariesTheme.sageLight;
      badgeFg = BeadariesTheme.sageDark;
    } else if (res.status == 'Rejected') {
      badgeBg = Colors.red.shade50;
      badgeFg = Colors.red.shade800;
    } else {
      badgeBg = BeadariesTheme.purpleLight;
      badgeFg = BeadariesTheme.purpleHint;
    }

    return Card(
      color: BeadariesTheme.creamCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  res.referenceId,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    res.status,
                    style: TextStyle(
                      color: badgeFg,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 22),
            _summaryRow('Item', res.productName),
            _summaryRow('Customer', res.customerName),
            _summaryRow('Fulfillment', res.fulfillmentMethod),
            if (res.customNotes.isNotEmpty)
              _summaryRow('Notes', res.customNotes),
            if (res.adminRemarks.isNotEmpty)
              _summaryRow('Owner Remarks', res.adminRemarks),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: BeadariesTheme.textMuted,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
