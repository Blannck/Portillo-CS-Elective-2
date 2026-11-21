import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'order_history_page.dart';

class CheckoutConfirmationPage extends StatelessWidget {
  final int orderId;
  final double totalAmount;

  const CheckoutConfirmationPage({
    super.key,
    required this.orderId,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmed'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Success Icon Animation/Circle
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle,
                    size: 56,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Thank You for Your Order!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Your pickleball gear order has been received and stored securely in the database.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.slateMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 28),

              // Order Details Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Order Number:',
                            style: TextStyle(
                              color: AppColors.slateMuted,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '#$orderId',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Status:',
                            style: TextStyle(
                              color: AppColors.slateMuted,
                              fontSize: 14,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withAlpha(30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'COMPLETED',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Paid:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // View Order History Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OrderHistoryPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('View in Order History'),
                ),
              ),
              const SizedBox(height: 12),

              // Back to Shopping Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text('Continue Shopping'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
