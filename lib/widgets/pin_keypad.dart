import 'package:flutter/material.dart';

class PinKeypad extends StatefulWidget {
  final TextEditingController controller;
  final void Function(String pin) onCompleted;
  final int pinLength;

  const PinKeypad({
    super.key,
    required this.controller,
    required this.onCompleted,
    this.pinLength = 4,
  });

  @override
  State<PinKeypad> createState() => _PinKeypadState();
}

class _PinKeypadState extends State<PinKeypad> {
  final _nodes = <FocusNode>[];
  final _controllers = <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.pinLength; i++) {
      _controllers.add(TextEditingController());
      _nodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final n in _nodes) { n.dispose(); }
    super.dispose();
  }

  void _onDigit(String digit) {
    for (var i = 0; i < widget.pinLength; i++) {
      if (_controllers[i].text.isEmpty) {
        setState(() {
          _controllers[i].text = digit;
        });
        if (i < widget.pinLength - 1) {
          _nodes[i + 1].requestFocus();
        } else {
          _nodes[i].unfocus();
          final pin = _controllers.map((c) => c.text).join();
          widget.onCompleted(pin);
        }
        return;
      }
    }
  }

  void _onDelete() {
    for (var i = widget.pinLength - 1; i >= 0; i--) {
      if (_controllers[i].text.isNotEmpty) {
        setState(() {
          _controllers[i].clear();
        });
        _nodes[i].requestFocus();
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.pinLength, (i) {
            return Container(
              width: 48,
              height: 56,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _controllers[i].text.isNotEmpty
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Text(
                  _controllers[i].text.isNotEmpty ? '●' : '',
                  style: TextStyle(
                    fontSize: 24,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 32),
        ...List.generate(3, (row) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (col) {
              final digit = '${row * 3 + col + 1}';
              return _KeyButton(
                label: digit,
                onTap: () => _onDigit(digit),
              );
            }),
          ),
        )),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 76),
              _KeyButton(
                label: '0',
                onTap: () => _onDigit('0'),
              ),
              _KeyButton(
                label: '⌫',
                onTap: _onDelete,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _KeyButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 72,
      height: 56,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: label == '⌫' ? 22 : 24,
                  fontWeight: label == '⌫' ? FontWeight.w300 : FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
