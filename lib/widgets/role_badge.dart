import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class RoleBadge extends StatelessWidget {
  final bool isAdmin;

  const RoleBadge({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin
            ? Colors.amber.shade100
            : AppColors.primary.withAlpha(40),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAdmin ? Colors.amber.shade700 : AppColors.primary,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAdmin ? Icons.admin_panel_settings : Icons.person,
            size: 14,
            color: isAdmin ? Colors.amber.shade900 : AppColors.primaryDark,
          ),
          const SizedBox(width: 4),
          Text(
            isAdmin ? 'ADMIN' : 'CUSTOMER',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isAdmin ? Colors.amber.shade900 : AppColors.primaryDark,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
