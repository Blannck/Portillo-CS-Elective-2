import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final bool isAdmin;
  final ValueChanged<String>? onStatusChanged;

  const OrderCard({
    super.key,
    required this.order,
    this.isAdmin = false,
    this.onStatusChanged,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'done':
      case 'delivered':
        return AppColors.success;
      case 'processing':
      case 'shipped':
        return AppColors.info;
      case 'pending':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.slateMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    final formattedDate = dateFormat.format(order.createdAt.toLocal());
    final statusColor = _getStatusColor(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID, Date, and Status Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        color: AppColors.slateMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                // Status Pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            // If Admin, show Customer Email / Name
            if (isAdmin && (order.customerEmail != null || order.customerName != null)) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16, color: AppColors.slateMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Customer: ${order.customerName ?? order.customerEmail}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Divider(height: 20),

            // Itemized List
            if (order.items.isNotEmpty) ...[
              for (final item in order.items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.quantity}x ${item.productName ?? "Product #${item.productId ?? ''}"}',
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '\$${item.subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              const Divider(height: 16),
            ],

            // Total Price and Admin status updater
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Paid',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),

            // Admin: Status Dropdown / Action
            if (isAdmin && onStatusChanged != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Update Status: ',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: ['pending', 'completed', 'processing', 'cancelled']
                            .contains(order.status.toLowerCase())
                        ? order.status.toLowerCase()
                        : 'completed',
                    isDense: true,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    items: const [
                      DropdownMenuItem(value: 'pending', child: Text('Pending')),
                      DropdownMenuItem(value: 'processing', child: Text('Processing')),
                      DropdownMenuItem(value: 'completed', child: Text('Completed')),
                      DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                    ],
                    onChanged: (val) {
                      if (val != null) onStatusChanged!(val);
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
