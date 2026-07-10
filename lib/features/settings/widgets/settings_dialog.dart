import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/core/widgets/royal_dialog.dart';
import 'package:url_launcher/link.dart';

const _kPrivacyPolicyUrl =
    'https://venusapps.com/apps/chaka/privacy-policy.html';
const _kTermsAndConditionsUrl =
    'https://venusapps.com/apps/chaka/terms-and-conditions.html';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showRoyalDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const SettingsDialog(),
    );
  }

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  bool _soundEffects = true;
  bool _backgroundMusic = true;
  // String _boardTheme = 'Classic';
  // String _language = 'English';

  // static const _boardThemes = ['Classic', 'Royal', 'Night'];
  // static const _languages = ['English', 'Hindi', 'Marathi'];

  void _resetToDefaults() {
    setState(() {
      _soundEffects = true;
      _backgroundMusic = true;
      // _boardTheme = 'Classic';
      // _language = 'English';
    });
  }

  // Future<void> _pickOption({
  //   required String title,
  //   required List<String> options,
  //   required String current,
  //   required ValueChanged<String> onSelected,
  // }) async {
  //   final selected = await showRoyalDialog<String>(
  //     context: context,
  //     builder: (ctx) => RoyalDialog(
  //       title: title,
  //       maxWidth: 280,
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           for (final option in options) ...[
  //             _SettingsPickerTile(
  //               label: option,
  //               isSelected: option == current,
  //               onTap: () => Navigator.of(ctx).pop(option),
  //             ),
  //             if (option != options.last) const SizedBox(height: 8),
  //           ],
  //         ],
  //       ),
  //     ),
  //   );
  //
  //   if (selected != null) onSelected(selected);
  // }

  @override
  Widget build(BuildContext context) {
    return RoyalDialog(
      title: 'SETTINGS',
      maxWidth: 340,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SettingsSectionLabel('SOUND'),
          _SettingsToggleRow(
            icon: Icons.volume_up_rounded,
            label: 'Sound Effects',
            value: _soundEffects,
            onChanged: (v) => setState(() => _soundEffects = v),
          ),
          _SettingsToggleRow(
            icon: Icons.music_note_rounded,
            label: 'Background Music',
            value: _backgroundMusic,
            onChanged: (v) => setState(() => _backgroundMusic = v),
          ),
          const _SettingsDivider(),
          const _SettingsSectionLabel('OTHER'),
          // _SettingsNavRow(
          //   icon: Icons.palette_rounded,
          //   label: 'Board Theme',
          //   value: _boardTheme,
          //   onTap: () => _pickOption(
          //     title: 'Board Theme',
          //     options: _boardThemes,
          //     current: _boardTheme,
          //     onSelected: (v) => setState(() => _boardTheme = v),
          //   ),
          // ),
          // _SettingsNavRow(
          //   icon: Icons.language_rounded,
          //   label: 'Language',
          //   value: _language,
          //   onTap: () => _pickOption(
          //     title: 'Language',
          //     options: _languages,
          //     current: _language,
          //     onSelected: (v) => setState(() => _language = v),
          //   ),
          // ),
          _SettingsLinkRow(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy Policy',
            url: _kPrivacyPolicyUrl,
          ),
          _SettingsLinkRow(
            icon: Icons.description_outlined,
            label: 'Terms and Conditions',
            url: _kTermsAndConditionsUrl,
          ),
          const SizedBox(height: 18),
          _SettingsResetButton(onTap: _resetToDefaults),
        ],
      ),
    );
  }
}

class _SettingsSectionLabel extends StatelessWidget {
  const _SettingsSectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: RoyalColors.brown.withValues(alpha: 0.75),
          letterSpacing: 1.2,
          height: 1.2,
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Divider(
        height: 1,
        thickness: 1,
        color: RoyalColors.brown.withValues(alpha: 0.22),
      ),
    );
  }
}

class _SettingsToggleRow extends StatelessWidget {
  const _SettingsToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 20, color: RoyalColors.brown),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: RoyalColors.darkBrown,
                height: 1.2,
              ),
            ),
          ),
          _RoyalToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SettingsLinkRow extends StatelessWidget {
  const _SettingsLinkRow({
    required this.icon,
    required this.label,
    required this.url,
  });

  final IconData icon;
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Link(
      uri: Uri.parse(url),
      target: LinkTarget.blank,
      builder: (context, followLink) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: followLink,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: RoyalColors.brown),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: RoyalColors.darkBrown,
                        height: 1.2,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: RoyalColors.brown.withValues(alpha: 0.65),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// class _SettingsNavRow extends StatelessWidget {
//   const _SettingsNavRow({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.onTap,
//   });
//
//   final IconData icon;
//   final String label;
//   final String value;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(10),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: Row(
//             children: [
//               Icon(icon, size: 20, color: RoyalColors.brown),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   label,
//                   style: const TextStyle(
//                     fontSize: 14.5,
//                     fontWeight: FontWeight.w700,
//                     color: RoyalColors.darkBrown,
//                     height: 1.2,
//                   ),
//                 ),
//               ),
//               Text(
//                 value,
//                 style: TextStyle(
//                   fontSize: 13.5,
//                   fontWeight: FontWeight.w600,
//                   color: RoyalColors.brown.withValues(alpha: 0.7),
//                   height: 1.2,
//                 ),
//               ),
//               const SizedBox(width: 4),
//               Icon(
//                 Icons.chevron_right_rounded,
//                 size: 22,
//                 color: RoyalColors.brown.withValues(alpha: 0.65),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class _RoyalToggle extends StatelessWidget {
  const _RoyalToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 48,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? RoyalColors.green : const Color(0xFFD4C4A8),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: value ? const Color(0xFF2D6E28) : const Color(0xFFB8A48A),
            width: 1.5,
          ),
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: RoyalColors.darkBrown.withValues(alpha: 0.25),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsResetButton extends StatelessWidget {
  const _SettingsResetButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 44,
          decoration: BoxDecoration(
            color: RoyalColors.outerRed,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: RoyalColors.gold, width: 2.2),
            boxShadow: [
              BoxShadow(
                color: RoyalColors.darkBrown.withValues(alpha: 0.28),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'RESET TO DEFAULT',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 0.6,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// class _SettingsPickerTile extends StatelessWidget {
//   const _SettingsPickerTile({
//     required this.label,
//     required this.isSelected,
//     required this.onTap,
//   });
//
//   final String label;
//   final bool isSelected;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
//           decoration: BoxDecoration(
//             color: isSelected ? const Color(0xFFFFF8EB) : Colors.transparent,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: isSelected ? RoyalColors.gold : const Color(0xFFD4B07A),
//               width: isSelected ? 2.2 : 1.4,
//             ),
//           ),
//           child: Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 14.5,
//                     fontWeight: FontWeight.w800,
//                     color: isSelected
//                         ? RoyalColors.darkBrown
//                         : RoyalColors.brown,
//                   ),
//                 ),
//               ),
//               if (isSelected)
//                 const Icon(
//                   Icons.check_rounded,
//                   color: RoyalColors.gold,
//                   size: 20,
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
