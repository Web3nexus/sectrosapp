import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'auth_notifier.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _selectedBusinessType = 'restaurant';
  final String _selectedCountry = 'NG';

  final List<Map<String, dynamic>> _businessTypes = [
    {'id': 'restaurant', 'label': 'Restaurant', 'icon': LucideIcons.utensils},
    {'id': 'cafe', 'label': 'Café', 'icon': LucideIcons.coffee},
    {'id': 'salon', 'label': 'Salon', 'icon': LucideIcons.scissors},
    {'id': 'hotel', 'label': 'Hotel', 'icon': LucideIcons.hotel},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authProvider.notifier).resetError();

    final success = await ref.read(authProvider.notifier).register({
      'name': _nameController.text.trim(),
      'business_name': _businessNameController.text.trim(),
      'business_type': _selectedBusinessType,
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'country': _selectedCountry,
    });

    if (success && mounted) {
      context.go('/dashboard');
    } else if (mounted) {
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Registration failed'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      LucideIcons.arrowLeft,
                      color: theme.colorScheme.onSurface,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                const SizedBox(height: 20),

                // Brand Logo & Title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      isDark
                          ? 'assets/images/logo_white.png'
                          : 'assets/images/logo_black.png',
                      height: 36,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Text(
                  'Create Business',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Start your journey with Sectros',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 24),

                // Error Message if any
                if (authState.error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.error.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.alertCircle,
                            size: 16, color: theme.colorScheme.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authState.error!,
                            style: TextStyle(
                              color: theme.colorScheme.error,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Full Name
                Text(
                  'Full Name',
                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
                  decoration: const InputDecoration(
                    hintText: 'John Doe',
                    prefixIcon: Icon(LucideIcons.user, size: 18),
                  ),
                ),
                const SizedBox(height: 16),

                // Business Name
                Text(
                  'Business Name',
                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _businessNameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Business name is required'
                      : null,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Lumina Bistro',
                    prefixIcon: Icon(LucideIcons.building2, size: 18),
                  ),
                ),
                const SizedBox(height: 20),

                // Business Category Selection
                Text(
                  'Business Category',
                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.6,
                  ),
                  itemCount: _businessTypes.length,
                  itemBuilder: (context, index) {
                    final type = _businessTypes[index];
                    final isSelected = _selectedBusinessType == type['id'];
                    return InkWell(
                      onTap: () => setState(() => _selectedBusinessType = type['id']),
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.18 : 0.08)
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline.withValues(alpha: isDark ? 0.4 : 0.7),
                            width: isSelected ? 1.8 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              type['icon'],
                              size: 17,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              type['label'],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Email Address
                Text(
                  'Email Address',
                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: 'owner@venue.com',
                    prefixIcon: Icon(LucideIcons.mail, size: 18),
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                Text(
                  'Password',
                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleRegister(),
                  validator: (v) =>
                      (v == null || v.length < 8) ? 'Must be at least 8 characters' : null,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(LucideIcons.lock, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                        size: 18,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 20,
                      tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Submit Button
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleRegister,
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Create Account'),
                ),
                const SizedBox(height: 24),

                // Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.only(left: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
