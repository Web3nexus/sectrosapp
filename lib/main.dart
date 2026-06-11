import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/dashboard/presentation/home_dashboard.dart';
import 'features/orders/presentation/orders_screen.dart';
import 'widgets/main_layout.dart';
import 'features/tables/presentation/tables_screen.dart';
import 'features/reservations/presentation/reservations_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/auth/presentation/forgot_password_screen.dart';
import 'features/menu/presentation/menu_screen.dart';
import 'features/staff/presentation/staff_screen.dart';
import 'features/notifications/presentation/notifications_screen.dart';
import 'features/billing/presentation/billing_screen.dart';
import 'features/waitlist/presentation/waitlist_screen.dart';
import 'features/shifts/presentation/shifts_screen.dart';
import 'models/user.dart';

final _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final container = ProviderScope.containerOf(context);
    final user = container.read(userProvider);
    final isLoggingIn = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation == '/forgot-password' ||
        state.matchedLocation == '/';

    if (user == null && !isLoggingIn) {
      return '/login';
    }

    if (user != null && isLoggingIn && state.matchedLocation != '/') {
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
    ShellRoute(
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const HomeDashboard(),
        ),
        GoRoute(
          path: '/orders',
          builder: (context, state) => const OrdersScreen(),
        ),
        GoRoute(
          path: '/menu',
          builder: (context, state) => const MenuScreen(),
        ),
        GoRoute(
          path: '/staff',
          builder: (context, state) => const StaffScreen(),
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
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/billing',
          builder: (context, state) => const BillingScreen(),
        ),
        GoRoute(
          path: '/waitlist',
          builder: (context, state) => const WaitlistScreen(),
        ),
        GoRoute(
          path: '/shifts',
          builder: (context, state) => const ShiftsScreen(),
        ),
      ],
    ),
  ],
);

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sectros',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
