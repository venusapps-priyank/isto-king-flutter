import 'dart:async';

import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/core/widgets/royal_dialog.dart';
import 'package:isto_king/features/daily_reward/models/daily_reward.dart';
import 'package:isto_king/features/daily_reward/services/daily_reward_service.dart';
import 'package:isto_king/features/daily_reward/widgets/daily_reward_reward_grid.dart';

class DailyRewardDialog extends StatefulWidget {
  const DailyRewardDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showRoyalDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const DailyRewardDialog(),
    );
  }

  @override
  State<DailyRewardDialog> createState() => _DailyRewardDialogState();
}

class _DailyRewardDialogState extends State<DailyRewardDialog> {
  final DailyRewardService _service = DailyRewardService();
  DailyRewardState? _state;
  bool _isLoading = true;
  bool _isClaiming = false;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadState() async {
    final state = await _service.loadState();
    if (!mounted) return;

    setState(() {
      _state = state;
      _isLoading = false;
    });
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!mounted || _state == null) return;

      if (_state!.canClaimToday) {
        final refreshed = await _service.loadState();
        if (!mounted) return;
        setState(() => _state = refreshed);
        return;
      }

      final remaining = _state!.nextRewardIn - const Duration(seconds: 1);
      setState(() {
        _state = DailyRewardState(
          days: _state!.days,
          currentStreak: _state!.currentStreak,
          nextRewardIn: remaining.isNegative ? Duration.zero : remaining,
          canClaimToday: _state!.canClaimToday,
        );
      });

      if (remaining.isNegative || remaining == Duration.zero) {
        final refreshed = await _service.loadState();
        if (!mounted) return;
        setState(() => _state = refreshed);
      }
    });
  }

  Future<void> _handleClaim() async {
    final state = _state;
    if (state == null || _isClaiming || !state.canClaimToday) return;

    setState(() => _isClaiming = true);
    final updatedState = await _service.claim();
    if (!mounted) return;

    setState(() {
      _state = updatedState;
      _isClaiming = false;
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final compact = screenSize.width < 380;
    final titleSize = screenSize.width < 340 ? 22.0 : 28.0;
    final horizontalInset = compact ? 12.0 : 24.0;
    final maxDialogHeight = screenSize.height -
        viewInsets.vertical -
        (compact ? 24.0 : 32.0);
    final state = _state;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: horizontalInset,
        vertical: compact ? 12 : 16,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 380,
          maxHeight: maxDialogHeight,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: RoyalColors.parchmentLight,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: RoyalColors.brown, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: RoyalColors.darkBrown.withValues(alpha: 0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Container(
                margin: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  color: RoyalColors.parchmentLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: RoyalColors.gold, width: 2.5),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 12 : 16,
                    compact ? 18 : 22,
                    compact ? 12 : 16,
                    compact ? 12 : 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: compact ? 4 : 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'DAILY REWARD',
                          style: TextStyle(
                            color: RoyalColors.darkBrown,
                            fontWeight: FontWeight.w900,
                            fontSize: titleSize,
                            letterSpacing: 0.8,
                            height: 1,
                          ),
                        ),
                      ),
                      SizedBox(height: compact ? 6 : 8),
                      const _SubtitleRow(),
                      SizedBox(height: compact ? 10 : 14),
                      if (_isLoading || state == null)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: CircularProgressIndicator(
                            color: RoyalColors.brown,
                          ),
                        )
                      else ...[
                        DailyRewardRewardGrid(days: state.days),
                        const SizedBox(height: 14),
                        _ClaimButton(
                          enabled: state.canClaimToday && !_isClaiming,
                          isLoading: _isClaiming,
                          onTap: _handleClaim,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.canClaimToday
                              ? 'Your reward is ready to claim!'
                              : 'Next reward in ${_formatDuration(state.nextRewardIn)}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: RoyalColors.brown.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: RoyalColors.brown,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Come back tomorrow',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -10,
              right: -8,
              child: _CloseButton(
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubtitleRow extends StatelessWidget {
  const _SubtitleRow();

  @override
  Widget build(BuildContext context) {
    const star = Icon(
      Icons.star_rounded,
      size: 12,
      color: RoyalColors.gold,
    );

    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        star,
        SizedBox(width: 6),
        Flexible(
          child: Text(
            'Come back every day to collect more!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: RoyalColors.brown,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        SizedBox(width: 6),
        star,
      ],
    );
  }
}

class _ClaimButton extends StatelessWidget {
  const _ClaimButton({
    required this.enabled,
    required this.onTap,
    this.isLoading = false,
  });

  final bool enabled;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFB51A1A), Color(0xFF7B0D06)],
              ),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: RoyalColors.gold, width: 2),
              boxShadow: [
                BoxShadow(
                  color: RoyalColors.darkBrown.withValues(alpha: 0.28),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 260;
                        final fontSize = compact ? 18.0 : 22.0;
                        final iconSize = compact ? 14.0 : 16.0;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_florist_rounded,
                              color: RoyalColors.gold,
                              size: iconSize,
                            ),
                            SizedBox(width: compact ? 6 : 8),
                            Text(
                              'CLAIM',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: fontSize,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(width: compact ? 6 : 8),
                            Icon(
                              Icons.local_florist_rounded,
                              color: RoyalColors.gold,
                              size: iconSize,
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: RoyalColors.outerRed,
          border: Border.all(color: Colors.white, width: 2),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}
