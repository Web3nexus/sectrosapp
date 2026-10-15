import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/user.dart';
import '../config/app_config.dart';

class SubscriptionGuard {
  /// Checks whether mutating actions are permitted.
  /// If expired, displays an explanatory modal and returns false.
  static bool canPerformAction(BuildContext context, WidgetRef ref, {String actionName = 'perform this action'}) {
    final user = ref.read(userProvider);

    if (user == null) return true;

    if (!user.isSubscriptionExpired) {
      return true;
    }

    _showExpiredDialog(context, user, actionName);
    return false;
  }

  static void _showExpiredDialog(BuildContext context, User user, String actionName) {
    final isStaff = user.isStaff;
    final billingUrl = user.webBillingUrl ?? '${AppConfig.baseUrl}/dashboard/billing';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.alertTriangle, color: Colors.red, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Subscription Expired',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isStaff
                  ? 'Your business subscription has expired. Creating new orders, bookings, or records is paused.\n\nPlease alert the business owner to renew the account on the Sectros web portal.'
                  : 'Your Sectros subscription has expired. You can view all your existing history and data, but cannot $actionName until renewed.',
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            if (!isStaff) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(LucideIcons.info, size: 16, color: Colors.amber),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Renewing on the web portal instantly restores full access across mobile and web.',
                        style: TextStyle(fontSize: 12, color: Colors.amber),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Dismiss'),
          ),
          if (!isStaff)
            FilledButton.icon(
              onPressed: () async {
                Navigator.of(ctx).pop();
                final uri = Uri.parse(billingUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(LucideIcons.externalLink, size: 16),
              label: const Text('Renew in Browser'),
            ),
        ],
      ),
    );
  }

  /// Launch external browser for subscription management
  static Future<void> openWebBilling(User? user) async {
    final billingUrl = user?.webBillingUrl ?? '${AppConfig.baseUrl}/dashboard/billing';
    final uri = Uri.parse(billingUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
