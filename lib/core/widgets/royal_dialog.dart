import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';

const _royalDialogTransitionDuration = Duration(milliseconds: 280);

Future<T?> showRoyalDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: _royalDialogTransitionDuration,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionBuilder: _royalDialogTransition,
  );
}

Widget _royalDialogTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final curved = CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeInCubic,
  );

  return FadeTransition(
    opacity: curved,
    child: ScaleTransition(
      scale: Tween<double>(begin: 0.86, end: 1).animate(curved),
      alignment: Alignment.center,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    ),
  );
}

class RoyalDialog extends StatelessWidget {
  const RoyalDialog({
    required this.title,
    required this.child,
    this.onClose,
    this.maxWidth = 320,
    this.insetPadding,
    super.key,
  });

  final String title;
  final Widget child;
  final VoidCallback? onClose;
  final double maxWidth;
  final EdgeInsets? insetPadding;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final effectiveInsetPadding =
        insetPadding ??
        EdgeInsets.symmetric(
          horizontal: screenSize.width < 360 ? 16 : 40,
          vertical: screenSize.height < 620 ? 14 : 24,
        );
    final maxDialogHeight = screenSize.height -
        effectiveInsetPadding.vertical -
        MediaQuery.viewInsetsOf(context).vertical;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: effectiveInsetPadding,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxDialogHeight,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: RoyalColors.parchmentLight,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: RoyalColors.gold, width: 3.5),
                boxShadow: [
                  BoxShadow(
                    color: RoyalColors.darkBrown.withValues(alpha: 0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _RoyalDialogHeader(title: title),
                    const SizedBox(height: 14),
                    child,
                  ],
                ),
              ),
            ),
            Positioned(
              top: -10,
              right: -8,
              child: _RoyalCloseButton(
                onTap: onClose ?? () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoyalDialogHeader extends StatelessWidget {
  const _RoyalDialogHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: RoyalColors.outerRed,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: RoyalColors.gold, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: RoyalColors.darkBrown.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 32,
          height: 1,
        ),
      ),
    );
  }
}

class _RoyalCloseButton extends StatelessWidget {
  const _RoyalCloseButton({required this.onTap});

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

class RoyalDialogActionButton extends StatelessWidget {
  const RoyalDialogActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.backgroundColor = RoyalColors.green,
    this.textColor = Colors.white,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.lerp(backgroundColor, Colors.white, 0.12) ?? backgroundColor,
              Color.lerp(backgroundColor, Colors.black, 0.24) ?? backgroundColor,
            ],
          ),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: RoyalColors.darkBrown.withValues(alpha: 0.28),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 19),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w800,
                fontSize: 19,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
