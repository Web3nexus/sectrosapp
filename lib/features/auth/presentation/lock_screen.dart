import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/biometric_service.dart';
import '../../../models/user.dart';
import '../../../widgets/pin_keypad.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> with WidgetsBindingObserver {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  String? _error;
  bool _isAuthenticating = false;
  bool _isSettingUpPin = false;
  bool _skipBiometricPrompt = false;
  // Incremented to force PinKeypad rebuild (clears internal dot state)
  int _pinStage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPinSetup();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isSettingUpPin && state == AppLifecycleState.resumed && !_isAuthenticating) {
      _tryBiometric();
    }
  }

  Future<void> _checkPinSetup() async {
    final bio = ref.read(biometricServiceProvider);
    final hasPin = await bio.hasPin();
    if (mounted) {
      setState(() => _isSettingUpPin = !hasPin);
      if (!hasPin) {
        _skipBiometricPrompt = true;
      } else {
        _tryBiometric();
      }
    }
  }

  Future<void> _tryBiometric() async {
    if (_isAuthenticating || _skipBiometricPrompt) return;
    final bio = ref.read(biometricServiceProvider);
    final enabled = await bio.isBiometricEnabled();
    if (!enabled) return;
    final available = await bio.isBiometricAvailable();
    if (!available) return;

    setState(() => _isAuthenticating = true);
    final success = await bio.authenticateWithBiometrics();
    setState(() => _isAuthenticating = false);

    if (success && mounted) {
      _unlock();
    }
  }

  void _onPinEntered(String pin) async {
    if (pin.length < 4) return;
    setState(() => _error = null);

    final bio = ref.read(biometricServiceProvider);
    final valid = await bio.verifyPin(pin);
    if (valid && mounted) {
      _unlock();
    } else {
      setState(() {
        _error = 'Incorrect PIN';
        _pinStage++; // clears PinKeypad dots via key rebuild
      });
      _pinController.clear();
    }
  }

  void _onPinSetup(String pin) async {
    if (pin.length < 4) return;
    setState(() {
      _error = null;
    });
    if (_confirmPinController.text.isEmpty) {
      setState(() {
        _confirmPinController.text = pin;
        _pinStage++; // forces PinKeypad to rebuild with empty dots
      });
      _pinController.clear();
    } else {
      if (_confirmPinController.text == pin) {
        final bio = ref.read(biometricServiceProvider);
        await bio.savePin(pin);
        final available = await bio.isBiometricAvailable();
        if (available && mounted) {
          final success = await bio.authenticateWithBiometrics(
            reason: 'Enable Face ID / Fingerprint for faster unlocking',
          );
          if (success) {
            await bio.setBiometricEnabled(true);
          }
        }
        await bio.setLockEnabled(true);
        if (mounted) _unlock();
      } else {
        setState(() {
          _error = 'PINs do not match';
          _confirmPinController.clear();
          _pinStage++; // reset PinKeypad dots
        });
        _pinController.clear();
      }
    }
  }

  void _unlock() {
    context.go('/dashboard');
  }

  void _skipPinSetup() async {
    final bio = ref.read(biometricServiceProvider);
    await bio.setLockEnabled(false);
    _unlock();
  }

  void _logout() async {
    final bio = ref.read(biometricServiceProvider);
    await bio.clear();
    ref.read(userProvider.notifier).logout();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Image.asset(
              isDark ? 'assets/images/icon_on_black.png' : 'assets/images/icon_on_white.png',
              width: 72,
              height: 72,
            ),
            const SizedBox(height: 24),
            Text(
              _isSettingUpPin ? 'Set App PIN' : 'Welcome back',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              _isSettingUpPin
                  ? (_confirmPinController.text.isEmpty
                      ? 'Create a 4-digit PIN for quick access'
                      : 'Confirm your PIN')
                  : 'Unlock to continue',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 40),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 18, color: theme.colorScheme.error),
                      const SizedBox(width: 8),
                      Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                    ],
                  ),
                ),
              ),
            PinKeypad(
              key: ValueKey(_pinStage),
              controller: _pinController,
              onCompleted: _isSettingUpPin ? _onPinSetup : _onPinEntered,
            ),
            const Spacer(),
            if (_isSettingUpPin) ...[
              TextButton(
                onPressed: _skipPinSetup,
                child: const Text('Skip — use full login next time'),
              ),
            ] else ...[
              FutureBuilder<bool>(
                future: ref.read(biometricServiceProvider).isBiometricEnabled(),
                builder: (context, snapshot) {
                  if (snapshot.data != true) return const SizedBox.shrink();
                  return FutureBuilder<bool>(
                    future: ref.read(biometricServiceProvider).isBiometricAvailable(),
                    builder: (context, available) {
                      if (available.data != true) return const SizedBox.shrink();
                      return TextButton.icon(
                        onPressed: _isAuthenticating ? null : _tryBiometric,
                        icon: _isAuthenticating
                            ? SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.fingerprint),
                        label: Text(_isAuthenticating ? 'Authenticating...' : 'Use Face ID / Fingerprint'),
                      );
                    },
                  );
                },
              ),
            ],
            const SizedBox(height: 8),
            TextButton(
              onPressed: _logout,
              child: Text('Sign out', style: TextStyle(color: theme.colorScheme.error)),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
