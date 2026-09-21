import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../widgets/common/skeleton_loader.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/error_view.dart';
import '../../../widgets/design_system/app_search_input.dart';
import '../../../widgets/design_system/filter_bar.dart';
import '../../../widgets/design_system/reservation_card.dart';
import '../../../widgets/design_system/app_button.dart';
import '../../../widgets/navigation/app_nav_menu.dart';
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
        leading: const AppNavMenuButton(),
        title: const Text('Bookings'),
        actions: [
          AppIconButton(
            icon: LucideIcons.share2,
            tooltip: 'Share booking link',
            hasBorder: false,
            onPressed: _handleShareLink,
          ),
          const SizedBox(width: AppSpacing.s4),
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

  Future<void> _handleShareLink() async {
    HapticFeedback.lightImpact();
    final url = await ref.read(reservationsProvider.notifier).fetchBookingUrl();
    if (!mounted) return;

    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No booking link available. Make sure your website is published.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    await _showShareSheet(url);
  }

  Future<void> _showShareSheet(String url) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Future<void> copy() async {
      await Clipboard.setData(ClipboardData(text: url));
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking link copied to clipboard')),
        );
      }
    }

    Future<void> share() async {
      // Capture the anchor rect before popping — UIActivityViewController
      // on iPad/macOS throws without a sharePositionOrigin.
      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null;
      if (context.mounted) Navigator.of(context).pop();
      await SharePlus.instance.share(
        ShareParams(text: url, sharePositionOrigin: origin),
      );
    }

    Future<void> open() async {
      final uri = Uri.tryParse(url);
      final launched = uri != null &&
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the link on this device.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.pagePadding,
          right: AppSpacing.pagePadding,
          bottom: MediaQuery.of(ctx).padding.bottom + AppSpacing.s16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share booking link',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Send this link to guests so they can book online. The restaurant confirms link/form bookings before they are marked confirmed.',
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: Text(
                url,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkPrimaryTeal : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Row(
              children: [
                Expanded(child: AppButton(label: 'Copy', icon: LucideIcons.copy, onPressed: copy)),
                const SizedBox(width: AppSpacing.s12),
                Expanded(child: AppButton(label: 'Share', icon: LucideIcons.send, onPressed: share)),
                const SizedBox(width: AppSpacing.s12),
                Expanded(child: AppButton(label: 'Open', icon: LucideIcons.externalLink, onPressed: open)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
