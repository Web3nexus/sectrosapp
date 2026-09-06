import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'billing_notifier.dart';
import '../../../models/billing_plan.dart';
import '../../../widgets/common/skeleton_loader.dart';
import '../../../widgets/common/error_view.dart';
import '../../../core/theme/app_colors.dart';

class BillingScreen extends ConsumerWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(billingProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Billing',
          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: () => ref.read(billingProvider.notifier).fetch(),
          ),
        ],
      ),
      body: _buildBody(context, state, ref),
    );
  }

  Widget _buildBody(BuildContext context, BillingState state, WidgetRef ref) {
    if (state.isLoading && state.plans.isEmpty) {
      return const SkeletonLoader(type: SkeletonType.card, itemCount: 3);
    }
    if (state.error != null && state.plans.isEmpty) {
      return ErrorView(
        message: state.error!,
        onRetry: () => ref.read(billingProvider.notifier).fetch(),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        if (state.currentPlan != null) _CurrentPlanCard(plan: state.currentPlan!),
        if (state.usage != null) ...[
          const SizedBox(height: 24),
          _UsageSection(usage: state.usage!),
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            Text('Plans', style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.foreground,
            )),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('${state.plans.length}',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...state.plans.map((plan) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _PlanCard(plan: plan, onUpgrade: () {
            if (!plan.isCurrent) {
              _confirmUpgrade(context, ref, plan);
            }
          }),
        )),
      ],
    );
  }

  void _confirmUpgrade(BuildContext context, WidgetRef ref, BillingPlan plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Upgrade to ${plan.name}?'),
        content: Text('You will be charged \$${plan.price.toStringAsFixed(0)}/${plan.interval}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(billingProvider.notifier).upgrade(plan.id);
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }
}

class _CurrentPlanCard extends StatelessWidget {
  final BillingPlan plan;
  const _CurrentPlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20, offset: const Offset(0, 10),
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
                child: const Text('CURRENT', style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1,
                )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(plan.name, style: const TextStyle(
            fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white,
          )),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${plan.price.toStringAsFixed(0)}', style: const TextStyle(
                fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white,
              )),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('/${plan.interval}', style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.7),
                )),
              ),
            ],
          ),
          if (plan.description != null) ...[
            const SizedBox(height: 8),
            Text(plan.description!, style: TextStyle(
              fontSize: 13, color: Colors.white.withValues(alpha: 0.8),
            )),
          ],
        ],
      ),
    );
  }
}

class _UsageSection extends ConsumerWidget {
  final Map<String, dynamic> usage;
  const _UsageSection({required this.usage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          Text('Usage', style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.foreground,
          )),
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
                      e.key.replaceAll('_', ' ')
                          .split(' ')
                          .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
                          .join(' '),
                      style: TextStyle(fontSize: 13, color: AppColors.mutedForeground),
                    ),
                  ),
                  Text(displayVal, style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.foreground,
                  )),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PlanCard extends ConsumerWidget {
  final BillingPlan plan;
  final VoidCallback onUpgrade;
  const _PlanCard({required this.plan, required this.onUpgrade});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCurrent = plan.isCurrent;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.primary.withValues(alpha: 0.05) : (isDark ? AppColors.darkCard : AppColors.card),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCurrent ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(plan.name, style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700, color: isCurrent ? AppColors.primary : AppColors.foreground,
              )),
              const Spacer(),
              Text('\$${plan.price.toStringAsFixed(0)}', style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.foreground,
              )),
              SizedBox(width: 4),
              Text('/${plan.interval}', style: TextStyle(
                fontSize: 12, color: AppColors.mutedForeground,
              )),
            ],
          ),
          if (plan.description != null) ...[
            const SizedBox(height: 6),
            Text(plan.description!, style: TextStyle(
              fontSize: 13, color: AppColors.mutedForeground,
            )),
          ],
          if (plan.features.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...plan.features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(LucideIcons.checkCircle, size: 16, color: AppColors.success),
                  const SizedBox(width: 10),
                  Expanded(child: Text(f, style: TextStyle(
                    fontSize: 13, color: AppColors.mutedForeground,
                  ))),
                ],
              ),
            )),
          ],
          if (!isCurrent) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onUpgrade,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Upgrade to ${plan.name}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
