import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/services/biometric_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../widgets/design_system/app_card.dart';
import '../../../widgets/pin_keypad.dart';

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() =>
      _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState
    extends ConsumerState<SecuritySettingsScreen> {
  bool _lockEnabled = false;
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  bool _hasPin = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final bio = ref.read(biometricServiceProvider);
    final results = await Future.wait([
      bio.isLockEnabled(),
      bio.isBiometricEnabled(),
      bio.isBiometricAvailable(),
      bio.hasPin(),
    ]);
    if (mounted) {
      setState(() {
        _lockEnabled = results[0];
        _biometricEnabled = results[1];
        _biometricAvailable = results[2];
        _hasPin = results[3];
        _loading = false;
      });
    }
  }

  Future<void> _toggleLock(bool value) async {
    final bio = ref.read(biometricServiceProvider);
    if (value && !_hasPin) {
      await _showChangePinSheet(isSetup: true);
      return;
    }
    await bio.setLockEnabled(value);
    if (mounted) setState(() => _lockEnabled = value);
  }

  Future<void> _toggleBiometric(bool value) async {
    final bio = ref.read(biometricServiceProvider);
    if (value) {
      final success = await bio.authenticateWithBiometrics(
        reason: 'Confirm your identity to enable biometric unlock',
      );
      if (!success) return;
    }
    await bio.setBiometricEnabled(value);
    if (mounted) setState(() => _biometricEnabled = value);
  }

  Future<void> _showChangePinSheet({bool isSetup = false}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChangePinSheet(
        isSetup: isSetup,
        onPinSaved: () async {
          final bio = ref.read(biometricServiceProvider);
          await bio.setLockEnabled(true);
          if (mounted) {
            setState(() {
              _lockEnabled = true;
              _hasPin = true;
            });
          }
        },
      ),
    );
    await _loadState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(title: const Text('Security & App Lock')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              children: [
                _SectionHeader(title: 'App Lock', isDark: isDark),
                const SizedBox(height: AppSpacing.s8),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SwitchTile(
                        icon: LucideIcons.lock,
                        title: 'Require PIN on Open',
                        subtitle: 'Lock the app when it goes to background',
                        value: _lockEnabled,
                        onChanged: _toggleLock,
                        isDark: isDark,
                      ),
                      if (_lockEnabled) ...[
                        const Divider(height: 1),
                        _ActionTile(
                          icon: LucideIcons.keyRound,
                          title: _hasPin ? 'Change PIN' : 'Set Up PIN',
                          subtitle: _hasPin
                              ? 'Update your 4-digit app PIN'
                              : 'Create a PIN to secure the app',
                          onTap: () => _showChangePinSheet(isSetup: !_hasPin),
                          isDark: isDark,
                        ),
                      ],
                    ],
                  ),
                ),
                if (_lockEnabled && _biometricAvailable) ...[
                  const SizedBox(height: AppSpacing.s20),
                  _SectionHeader(title: 'Biometric Unlock', isDark: isDark),
                  const SizedBox(height: AppSpacing.s8),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: _SwitchTile(
                      icon: LucideIcons.fingerprint,
                      title: 'Face ID / Fingerprint',
                      subtitle: 'Use biometrics instead of typing your PIN',
                      value: _biometricEnabled,
                      onChanged: _toggleBiometric,
                      isDark: isDark,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.s20),
                _SectionHeader(title: 'Info', isDark: isDark),
                const SizedBox(height: AppSpacing.s8),
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  child: Text(
                    'App Lock protects your data when you leave the app. '
                    'Your PIN is stored securely on this device and is never '
                    'sent to any server.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkElevated
                  : AppColors.secondaryBackground,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Center(
              child: Icon(icon, size: 18,
                  color: isDark
                      ? AppColors.darkPrimaryTeal
                      : AppColors.primary),
            ),
          ),
          const SizedBox(width: AppSpacing.s14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    )),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    )),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16, vertical: AppSpacing.s14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkElevated
                    : AppColors.secondaryBackground,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Center(
                child: Icon(icon, size: 18,
                    color: isDark
                        ? AppColors.darkPrimaryTeal
                        : AppColors.primary),
              ),
            ),
            const SizedBox(width: AppSpacing.s14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      )),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      )),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight,
                size: 18,
                color:
                    isDark ? AppColors.darkTextSecondary : AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _ChangePinSheet extends ConsumerStatefulWidget {
  final bool isSetup;
  final VoidCallback? onPinSaved;

  const _ChangePinSheet({required this.isSetup, this.onPinSaved});

  @override
  ConsumerState<_ChangePinSheet> createState() => _ChangePinSheetState();
}

class _ChangePinSheetState extends ConsumerState<_ChangePinSheet> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  int _stage = 0;
  String? _error;
  int _keypadKey = 0;

  @override
  void initState() {
    super.initState();
    _stage = widget.isSetup ? 1 : 0;
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onPin(String pin) async {
    if (pin.length < 4) return;
    final bio = ref.read(biometricServiceProvider);
    setState(() => _error = null);

    if (_stage == 0) {
      final valid = await bio.verifyPin(pin);
      if (!valid) {
        setState(() {
          _error = 'Incorrect current PIN';
          _keypadKey++;
        });
        _pinController.clear();
        return;
      }
      setState(() {
        _stage = 1;
        _keypadKey++;
      });
      _pinController.clear();
    } else if (_stage == 1) {
      setState(() {
        _confirmController.text = pin;
        _stage = 2;
        _keypadKey++;
      });
      _pinController.clear();
    } else {
      if (_confirmController.text == pin) {
        await bio.savePin(pin);
        widget.onPinSaved?.call();
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PIN updated successfully')),
          );
        }
      } else {
        setState(() {
          _error = 'PINs do not match — try again';
          _confirmController.clear();
          _stage = 1;
          _keypadKey++;
        });
        _pinController.clear();
      }
    }
  }

  String get _prompt {
    if (_stage == 0) return 'Enter your current PIN';
    if (_stage == 1) return 'Enter a new 4-digit PIN';
    return 'Confirm your new PIN';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.isSetup ? 'Set Up PIN' : 'Change PIN',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            _prompt,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _error!,
                style:
                    TextStyle(color: theme.colorScheme.error, fontSize: 13),
              ),
            ),
          ],
          const SizedBox(height: 16),
          PinKeypad(
            key: ValueKey(_keypadKey),
            controller: _pinController,
            onCompleted: _onPin,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
