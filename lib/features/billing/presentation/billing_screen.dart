import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'billing_notifier.dart';
import '../../../models/billing_plan.dart';
import '../../../models/user.dart';
import '../../../widgets/common/skeleton_loader.dart';
import '../../../widgets/common/error_view.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/config/app_config.dart';
import '../../../widgets/navigation/app_nav_menu.dart';

class BillingScreen extends ConsumerWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(billingProvider);
    final user = ref.watch(userProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const AppNavMenuButton(),
        title: Text(
          'Subscription & Billing',
          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: () => ref.read(billingProvider.notifier).fetch(),
          ),
        ],
      ),
      body: _buildBody(context, state, user, ref),
    );
  }

  Widget _buildBody(BuildContext context, BillingState state, User? user, WidgetRef ref) {
    if (state.isLoading && state.plans.isEmpty) {
      return const SkeletonLoader(type: SkeletonType.card, itemCount: 3);
    }
    if (state.error != null && state.plans.isEmpty) {
      return ErrorView(
        message: state.error!,
        onRetry: () => ref.read(billingProvider.notifier).fetch(),
      );
    }

    final isExpired = user?.isSubscriptionExpired == true;
    final webBillingUrl = user?.webBillingUrl ?? '${AppConfig.baseUrl}/dashboard/billing';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        // 1. Expiration Alert Banner if expired
        if (isExpired) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.alertTriangle, color: Colors.red, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Subscription Expired',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your business subscription has ended. New orders, bookings, and mutating actions are temporarily paused until renewed. Past data remains accessible in read-only mode.',
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _openBrowserBilling(webBillingUrl),
                    icon: const Icon(LucideIcons.externalLink, size: 16),
                    label: const Text('Renew Subscription in Web Browser'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // 2. Current Plan Card
        if (state.currentPlan != null)
          _CurrentPlanCard(
            plan: state.currentPlan!,
            user: user,
            isExpired: isExpired,
          ),

        const SizedBox(height: 16),

        // 3. Web Billing Portal Redirect Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(LucideIcons.globe, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Web Billing Portal',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Manage plans, invoices & tax compliance',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'To upgrade your plan, update credit cards, or manage billing settings, access the secure Sectros Web Portal directly in your browser (Safari / Chrome).',
                style: TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _openBrowserBilling(webBillingUrl),
                  icon: const Icon(LucideIcons.externalLink, size: 16),
                  label: const Text('Open Web Portal in Browser'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 4. Usage Section if available
        if (state.usage != null) ...[
          const SizedBox(height: 20),
          _UsageSection(usage: state.usage!),
        ],

        const SizedBox(height: 24),

        // 5. Available Plan Reference (No in-app purchase buttons)
        Row(
          children: [
            const Text(
              'Available Plans Overview',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${state.plans.length}',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'View plan specifications. Upgrades take place on the web portal.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),

        ...state.plans.map((plan) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _PlanReferenceCard(
            plan: plan,
            onOpenWeb: () => _openBrowserBilling(webBillingUrl),
          ),
        )),
      ],
    );
  }

  void _openBrowserBilling(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _CurrentPlanCard extends StatelessWidget {
  final BillingPlan plan;
  final User? user;
  final bool isExpired;

  const _CurrentPlanCard({
    required this.plan,
    this.user,
    required this.isExpired,
  });

  @override
  Widget build(BuildContext context) {
    String expiryText = '';
    if (user?.subscriptionEndsAt != null && user!.subscriptionEndsAt!.isNotEmpty) {
      try {
        final dt = DateTime.parse(user!.subscriptionEndsAt!);
        expiryText = '${isExpired ? 'Expired' : 'Renews'}: ${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isExpired
              ? [Colors.red.shade900, Colors.red.shade700]
              : [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isExpired ? Colors.red : AppColors.primary).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(LucideIcons.crown, color: Colors.white, size: 22),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isExpired ? 'EXPIRED' : 'ACTIVE PLAN',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            plan.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${plan.price.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '/${plan.interval}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          if (expiryText.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              expiryText,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UsageSection extends StatelessWidget {
  final Map<String, dynamic> usage;
  const _UsageSection({required this.usage});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Plan Usage', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          ...usage.entries.where((e) => e.key != 'plan_slug' && e.value != null).map((e) {
            String displayVal;
            if (e.value is Map) {
              final m = e.value as Map;
              final used = m['used'] ?? 0;
              final limit = m['limit'] ?? 0;
              displayVal = limit > 0 ? '$used / $limit' : '$used';
            } else if (e.value is bool) {
              displayVal = e.value ? 'Yes' : 'No';
            } else {
              displayVal = e.value.toString();
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      e.key
                          .replaceAll('_', ' ')
                          .split(' ')
                          .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
                          .join(' '),
                      style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground),
                    ),
                  ),
                  Text(
                    displayVal,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PlanReferenceCard extends StatelessWidget {
  final BillingPlan plan;
  final VoidCallback onOpenWeb;

  const _PlanReferenceCard({
    required this.plan,
    required this.onOpenWeb,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCurrent = plan.isCurrent;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.primary.withValues(alpha: 0.05)
            : (isDark ? AppColors.darkCard : AppColors.card),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCurrent
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                plan.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isCurrent ? AppColors.primary : null,
                ),
              ),
              if (isCurrent) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'CURRENT',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                '\$${plan.price.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 2),
              Text(
                '/${plan.interval}',
                style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
              ),
            ],
          ),
          if (plan.description != null) ...[
            const SizedBox(height: 6),
            Text(
              plan.description!,
              style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground),
            ),
          ],
          if (plan.features.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...plan.features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(LucideIcons.checkCircle, size: 15, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      f,
                      style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                    ),
                  ),
                ],
              ),
            )),
          ],
          if (!isCurrent) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onOpenWeb,
                icon: const Icon(LucideIcons.externalLink, size: 14),
                label: const Text('Upgrade on Web Portal', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
