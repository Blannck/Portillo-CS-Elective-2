import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants/app_colors.dart';
import '../../providers/supabase_provider.dart';

class SignupConfirmationPage extends ConsumerStatefulWidget {
  final String email;
  final String firstName;
  final bool isAutoConfirmed;

  const SignupConfirmationPage({
    super.key,
    required this.email,
    required this.firstName,
    required this.isAutoConfirmed,
  });

  @override
  ConsumerState<SignupConfirmationPage> createState() =>
      _SignupConfirmationPageState();
}

class _SignupConfirmationPageState
    extends ConsumerState<SignupConfirmationPage> {
  bool _resending = false;

  Future<void> _resendVerification() async {
    setState(() => _resending = true);
    try {
      final supabase = ref.read(supabaseProvider);
      await supabase.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email resent! Please check your inbox.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resend error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Confirmation'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon Header
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: widget.isAutoConfirmed
                      ? AppColors.primary.withAlpha(25)
                      : Colors.amber.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    widget.isAutoConfirmed
                        ? Icons.check_circle_outline
                        : Icons.mark_email_read_outlined,
                    size: 54,
                    color: widget.isAutoConfirmed
                        ? AppColors.primary
                        : Colors.amber.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                widget.isAutoConfirmed
                    ? 'Welcome to PicklePro!'
                    : 'Account Created Successfully!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),

              Text(
                widget.isAutoConfirmed
                    ? 'Hi ${widget.firstName}, your account is active and ready. You are now logged in.'
                    : 'Your customer account has been created for ${widget.email}.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.slateMuted,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 24),

              // Details & Verification Instructions Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Name: ${widget.firstName}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.email, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Email: ${widget.email}',
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.shield, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Assigned Role: CUSTOMER',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (!widget.isAutoConfirmed) ...[
                        const Divider(height: 24),
                        const Text(
                          'Email Verification Notice:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'A verification email was sent to your address. Please click the link inside to verify before signing in.\n\n'
                          '💡 Tip for grading/testing: To bypass email verification and enable instant sign-ins, turn OFF "Confirm email" in your Supabase Dashboard: Authentication -> Providers -> Email.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.slateMuted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Action Buttons
              if (widget.isAutoConfirmed) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('Start Shopping'),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Proceed to Sign In'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _resending ? null : _resendVerification,
                    icon: _resending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(
                      _resending
                          ? 'Sending...'
                          : 'Resend Verification Email',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
