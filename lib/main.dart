import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/brand_color_provider.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/lock_screen.dart';
import 'core/services/biometric_service.dart';
import 'features/dashboard/presentation/home_dashboard.dart';
import 'features/orders/presentation/orders_screen.dart';
import 'widgets/main_layout.dart';
import 'features/tables/presentation/tables_screen.dart';
import 'features/reservations/presentation/reservations_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/auth/presentation/forgot_password_screen.dart';
import 'features/staff/presentation/staff_dashboard_screen.dart';
import 'features/staff/presentation/staff_messages_screen.dart';
import 'features/staff/presentation/staff_screen.dart';
import 'features/notifications/presentation/notifications_screen.dart';
import 'features/inbox/presentation/inbox_screen.dart';
import 'features/finance/presentation/finance_screen.dart';
import 'features/billing/presentation/billing_screen.dart';
import 'features/calendar/presentation/calendar_screen.dart';
import 'features/customers/presentation/customers_screen.dart';
import 'features/settings/presentation/more_settings_screen.dart';
import 'models/user.dart';

final _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final container = ProviderScope.containerOf(context);
    final user = container.read(userProvider);
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation == '/forgot-password' ||
        state.matchedLocation == '/' ||
        state.matchedLocation == '/lock';

    if (user == null && !isAuthRoute) {
      return '/login';
    }

    if (user != null && isAuthRoute && state.matchedLocation != '/' && state.matchedLocation != '/lock') {
      return '/dashboard';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/lock',
      builder: (context, state) => const LockScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainLayout(child: _LockAwareShell(child: child)),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) {
            final container = ProviderScope.containerOf(context);
            final user = container.read(userProvider);
            if (user != null && user.isStaff) {
              return const StaffDashboardScreen();
            }
            return const HomeDashboard();
          },
        ),
        GoRoute(
          path: '/orders',
          builder: (context, state) => const OrdersScreen(),
        ),
        GoRoute(
          path: '/tables',
          builder: (context, state) => const TablesScreen(),
        ),
        GoRoute(
          path: '/reservations',
          builder: (context, state) => const ReservationsScreen(),
        ),
        GoRoute(
          path: '/inbox',
          builder: (context, state) => const InboxScreen(),
        ),
        GoRoute(
          path: '/finance',
          builder: (context, state) => const FinanceScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/staff-messages',
          builder: (context, state) => const StaffMessagesScreen(),
        ),
        GoRoute(
          path: '/staff',
          builder: (context, state) => const StaffScreen(),
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarScreen(),
        ),
        GoRoute(
          path: '/customers',
          builder: (context, state) => const CustomersScreen(),
        ),
        GoRoute(
          path: '/more',
          builder: (context, state) => const MoreSettingsScreen(),
        ),
        GoRoute(
          path: '/billing',
          builder: (context, state) => const BillingScreen(),
        ),
      ],
    ),
  ],
);

class _LockAwareShell extends ConsumerStatefulWidget {
  final Widget child;
  const _LockAwareShell({required this.child});

  @override
  ConsumerState<_LockAwareShell> createState() => _LockAwareShellState();
}

class _LockAwareShellState extends ConsumerState<_LockAwareShell>
    with WidgetsBindingObserver {
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      setState(() => _locked = true);
    }
    if (state == AppLifecycleState.resumed && _locked) {
      _showLockScreen();
    }
  }

  void _showLockScreen() {
    final bio = ref.read(biometricServiceProvider);
    bio.isLockEnabled().then((enabled) {
      if (enabled && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const LockScreen(),
            fullscreenDialog: true,
          ),
        ).then((_) {
          if (mounted) setState(() => _locked = false);
        });
      } else {
        if (mounted) setState(() => _locked = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

void main() {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandColor = ref.watch(brandColorProvider);
    return MaterialApp.router(
      title: 'Sectros',
      theme: AppTheme.buildLightTheme(brandColor),
      darkTheme: AppTheme.buildDarkTheme(brandColor),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
