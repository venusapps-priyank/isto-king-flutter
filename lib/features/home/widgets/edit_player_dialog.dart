import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/core/widgets/royal_dialog.dart';
import 'package:isto_king/data/avatar_assets.dart';
import 'package:isto_king/features/home/models/user_profile.dart';

class EditPlayerDialog extends StatefulWidget {
  const EditPlayerDialog({required this.initialProfile, super.key});

  final UserProfile initialProfile;

  static Future<UserProfile?> show(
    BuildContext context, {
    required UserProfile initialProfile,
  }) {
    return showRoyalDialog<UserProfile>(
      context: context,
      barrierDismissible: true,
      builder: (_) => EditPlayerDialog(initialProfile: initialProfile),
    );
  }

  @override
  State<EditPlayerDialog> createState() => _EditPlayerDialogState();
}

class _EditPlayerDialogState extends State<EditPlayerDialog> {
  late final TextEditingController _nameController;
  late String _selectedAvatar;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialProfile.name);
    _selectedAvatar = avatarAssets.contains(widget.initialProfile.avatarAsset)
        ? widget.initialProfile.avatarAsset
        : avatarAssets.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSave() {
    final name = _nameController.text.trim();
    Navigator.of(context).pop(
      UserProfile(
        name: name.isEmpty ? 'Player' : name,
        avatarAsset: _selectedAvatar,
        themeColor: widget.initialProfile.themeColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RoyalDialog(
      title: 'EDIT PLAYER',
      maxWidth: 360,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth = constraints.maxWidth;
          final sectionGap = contentWidth < 280 ? 14.0 : 18.0;
          const gridGap = 10.0;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _FieldLabel(text: 'Player Name'),
              const SizedBox(height: 6),
              _NameInputField(controller: _nameController),
              SizedBox(height: sectionGap),
              const _DecoratedSectionHeading(label: 'Choose Avatar'),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: gridGap,
                  crossAxisSpacing: gridGap,
                  childAspectRatio: 1,
                ),
                itemCount: avatarAssets.length,
                itemBuilder: (context, index) {
                  final asset = avatarAssets[index];
                  return _AvatarTile(
                    asset: asset,
                    isSelected: _selectedAvatar == asset,
                    onTap: () => setState(() => _selectedAvatar = asset),
                  );
                },
              ),
              SizedBox(height: contentWidth < 280 ? 16 : 20),
              Row(
                children: [
                  Expanded(
                    child: _DialogActionButton(
                      label: 'Cancel',
                      backgroundColor: RoyalColors.parchmentLight,
                      textColor: RoyalColors.darkBrown,
                      borderColor: RoyalColors.gold,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DialogActionButton(
                      label: 'Save',
                      backgroundColor: RoyalColors.red,
                      textColor: Colors.white,
                      borderColor: RoyalColors.gold,
                      showStars: true,
                      onTap: _onSave,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: RoyalColors.darkBrown,
        height: 1.1,
      ),
    );
  }
}

class _NameInputField extends StatelessWidget {
  const _NameInputField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: 16,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: RoyalColors.darkBrown,
        height: 1.1,
      ),
      decoration: InputDecoration(
        counterText: '',
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        filled: true,
        fillColor: const Color(0xFFFFF8EB),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD4B07A), width: 1.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: RoyalColors.gold, width: 2.2),
        ),
        suffixIcon: const Padding(
          padding: EdgeInsets.only(right: 10),
          child: Icon(
            Icons.edit,
            color: RoyalColors.brown,
            size: 18,
          ),
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
    );
  }
}

class _DecoratedSectionHeading extends StatelessWidget {
  const _DecoratedSectionHeading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: _GoldDivider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              color: RoyalColors.darkBrown,
              height: 1.1,
            ),
          ),
        ),
        const Expanded(child: _GoldDivider()),
      ],
    );
  }
}

class _GoldDivider extends StatelessWidget {
  const _GoldDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.4,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            RoyalColors.gold.withValues(alpha: 0.1),
            RoyalColors.gold,
            RoyalColors.gold.withValues(alpha: 0.1),
          ],
        ),
      ),
    );
  }
}

class _AvatarTile extends StatelessWidget {
  const _AvatarTile({
    required this.asset,
    required this.isSelected,
    required this.onTap,
  });

  final String asset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest.shortestSide;
        final checkSize = size * 0.34;

        return GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? RoyalColors.red
                        : const Color(0xFFC9A06A),
                    width: isSelected ? 4.2 : 1.8,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: RoyalColors.red.withValues(alpha: 0.35),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
                child: ClipOval(
                  child: ColoredBox(
                    color: RoyalColors.parchmentLight,
                    child: Image.asset(asset, fit: BoxFit.cover),
                  ),
                ),
              ),
              if (isSelected)
                Positioned(
                  right: -1,
                  bottom: -1,
                  child: Container(
                    width: checkSize,
                    height: checkSize,
                    decoration: const BoxDecoration(
                      color: RoyalColors.red,
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(
                        BorderSide(color: Colors.white, width: 1.4),
                      ),
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: checkSize * 0.62,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DialogActionButton extends StatelessWidget {
  const _DialogActionButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.onTap,
    this.showStars = false,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final VoidCallback onTap;
  final bool showStars;

  @override
  Widget build(BuildContext context) {
    final isPrimary = backgroundColor == RoyalColors.red;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          height: 42,
          decoration: BoxDecoration(
            gradient: isPrimary
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.lerp(backgroundColor, Colors.white, 0.14)!,
                      Color.lerp(backgroundColor, Colors.black, 0.18)!,
                    ],
                  )
                : null,
            color: isPrimary ? null : backgroundColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor, width: 2.4),
            boxShadow: [
              BoxShadow(
                color: RoyalColors.darkBrown.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showStars) ...[
                  Icon(Icons.auto_awesome, color: RoyalColors.gold, size: 13),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    height: 1,
                  ),
                ),
                if (showStars) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.auto_awesome, color: RoyalColors.gold, size: 13),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
