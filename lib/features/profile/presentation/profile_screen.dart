import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../models/user.dart';
import '../../../core/api/api_service.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/utils/api_error.dart';
import '../../../core/theme/app_colors.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    // Refresh user data (incl. plan) each time profile opens
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshUser());
  }

  Future<void> _refreshUser() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.client.get('/user');
      if (response.statusCode == 200 && mounted) {
        final user = User.fromJson(response.data);
        ref.read(userProvider.notifier).setUser(user);
      }
    } catch (_) {}
    if (mounted) setState(() => _refreshing = false);
  }

  void _showTokenSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ApiTokenSheet(api: ref.read(apiServiceProvider)),
    );
  }

  void _showSupportSheet() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(LucideIcons.headphones, size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text('Support Helpdesk',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Our support team is available 24/7 to help you with any issues.',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.mutedForeground),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            _SupportOptionTile(
              icon: LucideIcons.mail,
              title: 'Email Support',
              subtitle: 'support@sectros.com',
              onTap: () {
                Navigator.pop(ctx);
                _copyToClipboard('support@sectros.com', 'Email copied');
              },
            ),
            const SizedBox(height: 12),
            _SupportOptionTile(
              icon: LucideIcons.messageCircle,
              title: 'Live Chat',
              subtitle: 'Chat with us on WhatsApp',
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening WhatsApp support...')),
                );
              },
            ),
            const SizedBox(height: 12),
            _SupportOptionTile(
              icon: LucideIcons.bookOpen,
              title: 'Documentation',
              subtitle: 'Browse help articles & guides',
              onTap: () {
                Navigator.pop(ctx);
                _copyToClipboard('https://docs.sectros.com', 'Docs URL copied');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_refreshing)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            IconButton(
              icon: const Icon(LucideIcons.refreshCw, size: 18),
              tooltip: 'Refresh',
              onPressed: _refreshUser,
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshUser,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              _ProfileHeader(user: user),
              const SizedBox(height: 32),
              _SettingsGroup(
                title: 'BUSINESS INFO',
                items: [
                  _SettingsTile(
                    icon: LucideIcons.building,
                    title: 'Business Type',
                    subtitle: user?.businessType.toUpperCase() ?? 'N/A',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: LucideIcons.shieldCheck,
                    title: 'Role',
                    subtitle: user?.role.toUpperCase() ?? 'N/A',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: LucideIcons.creditCard,
                    title: 'Plan',
                    subtitle: (user?.plan ?? 'free').toUpperCase(),
                    trailing: _PlanBadge(plan: user?.plan ?? 'free'),
                    onTap: () => context.push('/billing'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _SettingsGroup(
                title: 'APPLICATION',
                items: [
                  _SettingsTile(
                    icon: LucideIcons.bell,
                    title: 'Notifications',
                    onTap: () => context.push('/notifications'),
                  ),
                  _SettingsTile(
                    icon: LucideIcons.shieldCheck,
                    title: 'Security & App Lock',
                    onTap: () => context.push('/security-settings'),
                  ),
                  _SettingsTile(
                    icon: LucideIcons.keyRound,
                    title: 'API Token',
                    onTap: _showTokenSheet,
                  ),
                  _SettingsTile(
                    icon: LucideIcons.helpCircle,
                    title: 'Support Helpdesk',
                    onTap: _showSupportSheet,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  final api = ref.read(apiServiceProvider);
                  await api.logout();
                  ref.read(userProvider.notifier).logout();
                  final bio = ref.read(biometricServiceProvider);
                  await bio.clear();
                  if (context.mounted) context.go('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                  foregroundColor: Theme.of(context).colorScheme.error,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.logOut, size: 18),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Plan Badge ─────────────────────────────────────────────────────────────

class _PlanBadge extends StatelessWidget {
  final String plan;
  const _PlanBadge({required this.plan});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (plan.toLowerCase()) {
      case 'pro':
        color = const Color(0xFF6C63FF);
        break;
      case 'enterprise':
        color = const Color(0xFFFFD700);
        break;
      default:
        color = AppColors.mutedForeground;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        plan.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }
}

// ─── API Token Sheet ─────────────────────────────────────────────────────────

class _ApiTokenSheet extends StatefulWidget {
  final ApiService api;
  const _ApiTokenSheet({required this.api});

  @override
  State<_ApiTokenSheet> createState() => _ApiTokenSheetState();
}

class _ApiTokenSheetState extends State<_ApiTokenSheet> {
  String? _token;
  bool _obscured = true;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = await widget.api.getToken();
      if (mounted) {
        setState(() { _token = token; _loading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  Future<void> _regenerateToken() async {
    setState(() { _loading = true; _error = null; });
    try {
      final response = await widget.api.client.post('/user/token');
      final newToken = response.data?['token'] as String?;
      if (newToken != null) {
        await widget.api.saveToken(newToken);
      }
      if (mounted) {
        setState(() { _token = newToken; _loading = false; });
      }
    } on DioException catch (e) {
      if (mounted) setState(() { _loading = false; _error = ApiError.fromDio(e).message; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(LucideIcons.keyRound, size: 18, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Text('API Token',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Use this token to authenticate API requests from external services.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
          else if (_error != null)
            Center(
              child: Column(
                children: [
                  Icon(LucideIcons.alertCircle, size: 32, color: theme.colorScheme.error),
                  const SizedBox(height: 8),
                  Text(_error!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _loadToken,
                    icon: const Icon(LucideIcons.refreshCw, size: 14),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            )
          else if (_token == null || _token!.isEmpty)
            Center(
              child: Column(
                children: [
                  const Icon(LucideIcons.keyRound, size: 40, color: AppColors.mutedForeground),
                  const SizedBox(height: 8),
                  Text('No API token found.', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _regenerateToken,
                    icon: const Icon(LucideIcons.plus, size: 14),
                    label: const Text('Generate Token'),
                  ),
                ],
              ),
            )
          else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      _obscured ? _maskToken(_token!) : _token!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _IconBtn(
                    icon: _obscured ? LucideIcons.eye : LucideIcons.eyeOff,
                    onPressed: () => setState(() => _obscured = !_obscured),
                    tooltip: _obscured ? 'Reveal' : 'Hide',
                  ),
                  const SizedBox(width: 4),
                  _IconBtn(
                    icon: LucideIcons.copy,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _token!));
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Token copied'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    tooltip: 'Copy',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Keep this token secret. Do not share it publicly.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _maskToken(String token) {
    if (token.length <= 8) return '*' * token.length;
    return '${token.substring(0, 6)}${'*' * (token.length - 10)}${token.substring(token.length - 4)}';
  }
}

// ─── Support Option Tile ──────────────────────────────────────────────────────

class _SupportOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SupportOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.mutedForeground),
          ],
        ),
      ),
    );
  }
}

// ─── Shared icon button ──────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const _IconBtn({required this.icon, required this.onPressed, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36, height: 36,
      child: IconButton(
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        splashRadius: 18,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
      ),
    );
  }
}

// ─── Profile header ──────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final User? user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final initials = user?.name.isNotEmpty == true
        ? user!.name.split(' ').take(2).map((w) => w[0]).join().toUpperCase()
        : 'U';

    return Column(
      children: [
        Container(
          width: 100, height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(initials,
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user?.name ?? 'User Name',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          user?.email ?? 'email@example.com',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        ),
        if (user?.platformName != null) ...[
          const SizedBox(height: 6),
          Text(
            user!.platformName!,
            style: TextStyle(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Settings group ──────────────────────────────────────────────────────────

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<_SettingsTile> items;
  const _SettingsGroup({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

// ─── Settings tile ────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 18, color: Theme.of(context).primaryColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: trailing ??
          (subtitle != null
              ? Text(subtitle!, style: TextStyle(color: Colors.grey.shade500, fontSize: 12))
              : const Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }
}
