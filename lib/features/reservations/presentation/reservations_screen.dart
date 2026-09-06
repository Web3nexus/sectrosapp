import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../widgets/common/skeleton_loader.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/error_view.dart';
import '../../../widgets/design_system/app_search_input.dart';
import '../../../widgets/design_system/filter_bar.dart';
import '../../../widgets/design_system/reservation_card.dart';
import '../../../widgets/design_system/app_button.dart';
import 'reservation_notifier.dart';
import 'create_booking_sheet.dart';
import 'reservation_detail_screen.dart';

class ReservationsScreen extends ConsumerStatefulWidget {
  const ReservationsScreen({super.key});

  @override
  ConsumerState<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends ConsumerState<ReservationsScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resState = ref.watch(reservationsProvider);

    // Compute filter counts
    final allList = resState.reservations;
    final confirmedCount = allList.where((r) => r.status.toLowerCase().contains('confirm') || r.status.toLowerCase() == 'active').length;
    final pendingCount = allList.where((r) => r.status.toLowerCase().contains('pend') || r.status.toLowerCase() == 'waiting').length;
    final arrivedCount = allList.where((r) => r.status.toLowerCase() == 'arrived' || r.status.toLowerCase() == 'seated').length;
    final cancelledCount = allList.where((r) => r.status.toLowerCase().contains('cancel')).length;

    final filterItems = [
      FilterItem(key: 'all', label: 'All Bookings', count: allList.length),
      FilterItem(key: 'confirmed', label: 'Confirmed', count: confirmedCount),
      FilterItem(key: 'pending', label: 'Pending', count: pendingCount),
      FilterItem(key: 'seated', label: 'Seated', count: arrivedCount),
      FilterItem(key: 'cancelled', label: 'Cancelled', count: cancelledCount),
    ];

    // Filter and search
    final filteredReservations = allList.where((res) {
      // Filter by status
      if (_selectedFilter != 'all') {
        final st = res.status.toLowerCase();
        if (_selectedFilter == 'confirmed' && !st.contains('confirm') && st != 'active') return false;
        if (_selectedFilter == 'pending' && !st.contains('pend') && st != 'waiting') return false;
        if (_selectedFilter == 'seated' && st != 'arrived' && st != 'seated') return false;
        if (_selectedFilter == 'cancelled' && !st.contains('cancel')) return false;
      }

      // Search query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final nameMatch = res.customerName.toLowerCase().contains(q);
        final idMatch = '#${res.id}'.contains(q);
        final phoneMatch = (res.phone ?? '').toLowerCase().contains(q);
        if (!nameMatch && !idMatch && !phoneMatch) return false;
      }

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Bookings'),
        actions: [
          AppIconButton(
            icon: LucideIcons.calendarPlus,
            tooltip: 'Add Reservation',
            hasBorder: false,
            onPressed: () {
              HapticFeedback.lightImpact();
              CreateBookingSheet.show(context);
            },
          ),
          const SizedBox(width: AppSpacing.s8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          await ref.read(reservationsProvider.notifier).fetchReservations();
        },
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.s8),
            // Search Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: AppSearchInput(
                controller: _searchController,
                hintText: 'Search guest name, phone, booking ID...',
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                onClear: () => setState(() => _searchQuery = ''),
              ),
            ),
            const SizedBox(height: AppSpacing.s12),

            // Status Filter Bar
            FilterBar(
              items: filterItems,
              selectedKey: _selectedFilter,
              onSelected: (key) {
                HapticFeedback.selectionClick();
                setState(() => _selectedFilter = key);
              },
            ),
            const SizedBox(height: AppSpacing.s12),

            // List or Skeletons / Empty
            Expanded(
              child: _buildList(resState, filteredReservations),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(ReservationsState state, List<dynamic> filtered) {
    if (state.isLoading && state.reservations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.pagePadding),
        child: SkeletonLoader(type: SkeletonType.reservation, itemCount: 6),
      );
    }
    if (state.error != null && state.reservations.isEmpty) {
      return Center(
        child: ErrorView(
          message: state.error!,
          onRetry: () => ref.read(reservationsProvider.notifier).fetchReservations(),
        ),
      );
    }
    if (filtered.isEmpty) {
      return Center(
        child: EmptyState(
          icon: LucideIcons.calendarCheck,
          title: _searchQuery.isNotEmpty ? 'No bookings found' : 'No reservations',
          subtitle: _searchQuery.isNotEmpty
              ? 'Try changing your search terms or filter'
              : 'Add your first guest reservation to manage it here',
          actionLabel: _searchQuery.isEmpty ? 'New Reservation' : null,
          onAction: _searchQuery.isEmpty
              ? () {
                  HapticFeedback.lightImpact();
                  CreateBookingSheet.show(context);
                }
              : null,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, 0, AppSpacing.pagePadding, 100),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final res = filtered[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s10),
          child: ReservationCard(
            reservation: res,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ReservationDetailScreen(reservation: res),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
