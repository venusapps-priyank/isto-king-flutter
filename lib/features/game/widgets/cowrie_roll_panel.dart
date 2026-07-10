import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:istochaka/features/game/logic/cowrie_animation_constants.dart';
import 'package:istochaka/features/game/logic/cowrie_logic.dart';
import 'package:istochaka/features/game/widgets/cowrie_shell.dart';

class CowrieRollPanel extends StatefulWidget {
  const CowrieRollPanel({
    required this.playerColor,
    required this.showShells,
    required this.canRoll,
    required this.resetSerial,
    required this.shellCount,
    required this.shellSize,
    this.alignRight = false,
    this.enableTap = true,
    this.autoRollSerial = 0,
    this.onRollStarted,
    this.onRollComplete,
    super.key,
  });

  final Color playerColor;
  final bool showShells;
  final bool canRoll;
  final int resetSerial;
  final int shellCount;
  final double shellSize;
  final bool alignRight;
  final bool enableTap;
  final int autoRollSerial;
  final VoidCallback? onRollStarted;
  final ValueChanged<int>? onRollComplete;

  @override
  State<CowrieRollPanel> createState() => _CowrieRollPanelState();
}

class _CowrieRollPanelState extends State<CowrieRollPanel> {
  final math.Random _random = math.Random();
  late List<bool> _cowries;
  List<bool>? _rollingCowries;
  bool _isRolling = false;
  int _rollCycle = 0;

  @override
  void initState() {
    super.initState();
    _cowries = List<bool>.filled(widget.shellCount, false);
    _scheduleAutoRollIfNeeded();
  }

  void _scheduleAutoRollIfNeeded() {
    if (widget.autoRollSerial <= 0 || !widget.canRoll || _isRolling) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _rollCowries();
    });
  }

  @override
  void didUpdateWidget(covariant CowrieRollPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shellCount != widget.shellCount) {
      _cowries = List<bool>.filled(widget.shellCount, false);
    }
    if (oldWidget.resetSerial != widget.resetSerial) {
      _cowries = List<bool>.filled(widget.shellCount, false);
      _rollingCowries = null;
      _isRolling = false;
    }
    if (oldWidget.showShells && !widget.showShells) {
      _cowries = List<bool>.filled(widget.shellCount, false);
      _rollingCowries = null;
      _isRolling = false;
    }
    if (widget.autoRollSerial != oldWidget.autoRollSerial) {
      _scheduleAutoRollIfNeeded();
    }
  }

  Future<void> _rollCowries() async {
    if (!widget.canRoll || _isRolling) return;

    final finalCowries =
        CowrieLogic.generateFinalCowries(widget.shellCount, _random);
    final result = CowrieLogic.calculateIstoValue(finalCowries);
    final nextRollCycle = _rollCycle + 1;

    setState(() {
      _isRolling = true;
      _rollCycle = nextRollCycle;
      _rollingCowries = finalCowries;
    });
    widget.onRollStarted?.call();

    await Future<void>.delayed(
      Duration(
        milliseconds:
            cowrieDelayMs * (widget.shellCount - 1) +
            cowrieSpinMs +
            cowrieSettleMs +
            80,
      ),
    );
    if (!mounted || _rollCycle != nextRollCycle) return;

    setState(() {
      _cowries = finalCowries;
      _rollingCowries = null;
      _isRolling = false;
    });

    widget.onRollComplete?.call(result);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showShells) {
      return SizedBox(height: widget.shellSize);
    }

    return Semantics(
      button: true,
      enabled: true,
      label: 'Roll cowries',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.enableTap ? _rollCowries : null,
        child: SizedBox(
          width: double.infinity,
          height: widget.shellSize,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final shellWidth = widget.shellSize * 0.68;
              final desiredGap = widget.shellSize * 0.2;
              final fittedGap = widget.shellCount <= 1
                  ? 0.0
                  : (constraints.maxWidth - shellWidth * widget.shellCount) /
                        (widget.shellCount - 1);
              final gap = math.max(0.0, math.min(desiredGap, fittedGap));
              final step = shellWidth + gap;
              final rowWidth =
                  shellWidth * widget.shellCount +
                  gap * (widget.shellCount - 1);
              final startX = widget.alignRight
                  ? constraints.maxWidth - rowWidth
                  : 0.0;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  for (var index = 0; index < widget.shellCount; index++)
                    Positioned(
                      left: startX + step * index,
                      top: 0,
                      child: CowrieShell(
                        startOpen: _cowries[index],
                        resultOpen:
                            _rollingCowries?[index] ?? _cowries[index],
                        isRolling: _isRolling,
                        rollCycle: _rollCycle,
                        delayIndex: index,
                        size: widget.shellSize,
                        width: shellWidth,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
