// Covers UI-07 Admin Reservation Review & Approval Dashboard FR-07 + Business Rule BR-02

import 'package:material_ui/material_ui.dart';

import '../services/reservation_store.dart';
import '../theme/beadaries_theme.dart';

class AdminReservationApprovalScreen extends StatefulWidget {
  const AdminReservationApprovalScreen({super.key});

  @override
  State<AdminReservationApprovalScreen> createState() =>
      _AdminReservationApprovalScreenState();
}

class _AdminReservationApprovalScreenState
    extends State<AdminReservationApprovalScreen> {
  final _store = ReservationStore.instance;
  String _selectedFilter = 'All';

  void _openDecisionDialog(ReservationModel reservation, bool isApprove) {
    final remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BeadariesTheme.creamCard,
        title: Text(
          isApprove ? 'Approve Reservation?' : 'Reject Reservation?',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isApprove
                  ? 'Item "${reservation.productName}" will be marked as Reserved.'
                  : 'Item "${reservation.productName}" will automatically revert to Available (BR-02).',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: remarksController,
              decoration: const InputDecoration(
                labelText: 'Optional Owner Remark',
                hintText: 'e.g., Pickup at FSKTM lobby Friday 2 PM',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove
                  ? BeadariesTheme.sageGreen
                  : Colors.red.shade600,
            ),
            onPressed: () {
              _store.reviewReservation(
                referenceId: reservation.referenceId,
                isApproved: isApprove,
                remarks: remarksController.text,
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isApprove
                        ? 'Approved ${reservation.referenceId} — Product set to Reserved'
                        : 'Rejected ${reservation.referenceId} — Product released to Available',
                  ),
                ),
              );
            },
            child: Text(isApprove ? 'Confirm Approve' : 'Confirm Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        final filtered = _selectedFilter == 'All'
            ? _store.reservations
            : _store.reservations
                  .where((r) => r.status == _selectedFilter)
                  .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Admin Reservations'),
          ), //FR-07: Admin Approve or Reject
          body: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: ['All', 'Pending', 'Approved', 'Rejected']
                      .map(
                        (filter) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: _selectedFilter == filter,
                            selectedColor: BeadariesTheme.purpleLight,
                            onSelected: (_) =>
                                setState(() => _selectedFilter = filter),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text('No reservations under this filter.'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final res = filtered[index];
                          final isPending = res.status == 'Pending';
                          return Card(
                            color: BeadariesTheme.creamCard,
                            margin: const EdgeInsets.only(bottom: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: BeadariesTheme.sageGreen.withValues(
                                  alpha: 0.25,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        res.referenceId,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: BeadariesTheme.purpleHint,
                                        ),
                                      ),
                                      Chip(
                                        label: Text(
                                          res.status,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                        backgroundColor:
                                            res.status == 'Approved'
                                            ? BeadariesTheme.sageLight
                                            : res.status == 'Rejected'
                                            ? Colors.red.shade50
                                            : BeadariesTheme.purpleLight,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${res.productName} (RM ${res.priceMYR.toStringAsFixed(2)})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Customer: ${res.customerName} (${res.customerPhone})',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  Text(
                                    'Fulfillment: ${res.fulfillmentMethod}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  if (res.customNotes.isNotEmpty)
                                    Text(
                                      'Notes: ${res.customNotes}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: BeadariesTheme.textMuted,
                                      ),
                                    ),
                                  if (res.adminRemarks.isNotEmpty)
                                    Text(
                                      'Admin Remark: ${res.adminRemarks}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: BeadariesTheme.sageDark,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  if (isPending) ...[
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor:
                                                  Colors.red.shade700,
                                              side: BorderSide(
                                                color: Colors.red.shade400,
                                              ),
                                            ),
                                            onPressed: () =>
                                                _openDecisionDialog(res, false),
                                            icon: const Icon(
                                              Icons.close,
                                              size: 18,
                                            ),
                                            label: const Text('Reject'),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () =>
                                                _openDecisionDialog(res, true),
                                            icon: const Icon(
                                              Icons.check,
                                              size: 18,
                                            ),
                                            label: const Text('Approve'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
