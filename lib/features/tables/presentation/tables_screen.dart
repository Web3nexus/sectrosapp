import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'table_notifier.dart';
import '../../../models/user.dart';
import '../../../models/table.dart';
import '../../../widgets/common/skeleton_loader.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/error_view.dart';

class TablesScreen extends ConsumerWidget {
  const TablesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableState = ref.watch(tablesProvider);
    final user = ref.watch(userProvider);

    String title = 'Tables';
    IconData icon = LucideIcons.layoutGrid;

    if (user != null) {
      if (user.businessType == 'hotel') {
        title = 'Rooms';
        icon = LucideIcons.bed;
      } else if (user.businessType == 'salon') {
        title = 'Stations';
        icon = LucideIcons.scissors;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: () => ref.read(tablesProvider.notifier).fetchTables(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(context, ref, tableState, icon),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, TablesState state, IconData icon) {
    if (state.isLoading && state.tables.isEmpty) {
      return const SkeletonLoader(type: SkeletonType.grid, itemCount: 4);
    }
    if (state.error != null && state.tables.isEmpty) {
      return ErrorView(
        message: state.error!,
        onRetry: () => ref.read(tablesProvider.notifier).fetchTables(),
      );
    }
    if (state.tables.isEmpty) {
      return const EmptyState(
        icon: LucideIcons.layoutGrid,
        title: 'No tables yet',
        subtitle: 'Add tables to manage your floor plan',
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: state.tables.length,
      itemBuilder: (context, index) {
        final table = state.tables[index];
        return _TableCard(table: table, icon: icon);
      },
    );
  }
}

class _TableCard extends StatelessWidget {
  final TableModel table;
  final IconData icon;
  const _TableCard({required this.table, required this.icon});

  @override
  Widget build(BuildContext context) {
    final bool isOccupied = table.status == 'occupied';
    final bool isReserved = table.status == 'reserved';

    Color statusColor = const Color(0xFF10B981);
    if (isOccupied) statusColor = const Color(0xFFEF4444);
    if (isReserved) statusColor = const Color(0xFFF59E0B);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: statusColor, size: 20),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        table.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      table.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Capacity: ${table.capacity}',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
