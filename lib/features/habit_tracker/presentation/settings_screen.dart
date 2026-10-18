import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitera/app_provider.dart';
import 'package:habitera/constants/color_picker.dart';
import 'package:habitera/constants/enums.dart';
import 'package:habitera/features/auth/presentation/auth_provider.dart';
import 'package:habitera/features/habit_tracker/presentation/widgets/custom_switch.dart';
import 'package:habitera/features/settings/presentation/settings_provider.dart';
import 'package:habitera/router/app_router.dart';
import 'package:habitera/utils/extensions.dart';
import 'package:habitera/utils/time_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Settings — replaces Profile as the third tab. Identity row up top, then
/// grouped preference rows.
/// design/Habitera Design System/ui_kits/habitera_app_v2/SettingsScreenV2.jsx
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Rebuild identity row after auth events (e.g. edit-profile's updateUser).
    ref.watch(authStateProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? '';
    final name = (user?.userMetadata?['name'] as String?)?.trim() ?? '';
    final version = ref.watch(appVersionProvider).value ?? '1.0.0';

    final themeMode = ref.watch(themeModeProvider);
    final weekStart = ref.watch(weekStartProvider);
    final remindersEnabled = ref.watch(remindersEnabledProvider);
    final defaultReminderTime = ref.watch(defaultReminderTimeProvider);

    final dark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = dark ? ColorPicker.darkTextTitle : ColorPicker.ink900;
    final mutedColor = dark ? ColorPicker.darkTextMuted : ColorPicker.ink500;

    final appearanceLabel = switch (themeMode) {
      ThemeMode.dark => 'Dark',
      ThemeMode.light => 'Light',
      ThemeMode.system => 'System',
    };

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Text(
                'Settings',
                style: context.screenTitle.copyWith(
                  fontSize: 30,
                  color: titleColor,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 96),
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: ColorPicker.sky50,
                        child: Text(
                          _initials(name),
                          style: context.body.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: ColorPicker.sky800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              overflow: TextOverflow.ellipsis,
                              style: context.body.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              overflow: TextOverflow.ellipsis,
                              style: context.small.copyWith(
                                fontSize: 14,
                                color: mutedColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SettingsGroup(
                    title: 'Account',
                    children: [
                      _SettingsRow(
                        icon: Icons.person_outline_rounded,
                        label: 'Edit profile',
                        onTap: () => _openEditProfile(context, name),
                      ),
                      _SettingsRow(
                        icon: Icons.lock_outline_rounded,
                        label: 'Change password',
                        divider: true,
                        onTap: () => context.pushNamed(
                          AppRoutes.changePasswordScreen.name,
                        ),
                      ),
                      _SettingsRow(
                        icon: Icons.delete_outline_rounded,
                        label: 'Delete account',
                        divider: true,
                        onTap: () => _confirmDeleteAccount(context, ref),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SettingsGroup(
                    title: 'Preferences',
                    children: [
                      _SettingsRow(
                        icon: Icons.dark_mode_outlined,
                        label: 'Appearance',
                        value: appearanceLabel,
                        onTap: () =>
                            _openAppearanceSheet(context, ref, themeMode),
                      ),
                      _SettingsRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Week starts on',
                        value: weekStart.label,
                        divider: true,
                        onTap: () =>
                            _openWeekStartSheet(context, ref, weekStart),
                      ),
                      _SettingsRow(
                        icon: Icons.access_time_outlined,
                        label: 'Default reminder time',
                        value: defaultReminderTime.format(context),
                        divider: true,
                        onTap: () => _pickDefaultReminderTime(
                          context,
                          ref,
                          defaultReminderTime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SettingsGroup(
                    title: 'Notifications',
                    children: [
                      _SettingsRow(
                        icon: Icons.notifications_none_rounded,
                        label: 'Reminders',
                        control: CustomSwitch(
                          value: remindersEnabled,
                          width: 47,
                          height: 26,
                          activeColor: ColorPicker.success,
                          inactiveColor: dark
                              ? ColorPicker.darkBorderDefault
                              : ColorPicker.ink200,
                          onChanged: (value) => ref
                              .read(remindersEnabledProvider.notifier)
                              .setEnabled(value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SettingsGroup(
                    title: 'About',
                    children: [
                      _SettingsRow(
                        icon: Icons.info_outline_rounded,
                        label: 'Version',
                        value: version,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dark
                            ? ColorPicker.sky600
                            : ColorPicker.ink900,
                        foregroundColor: dark
                            ? ColorPicker.darkTextTitle
                            : ColorPicker.white,

                        // backgroundColor: dark
                        //     ? ColorPicker.darkActionQuiet
                        //     : ColorPicker.ink900,
                        // foregroundColor: dark
                        //     ? ColorPicker.darkTextTitle
                        //     : ColorPicker.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: context.body.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () async {
                        await ref.read(authServiceProvider).signOut();
                      },
                      child: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAppearanceSheet(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
  ) {
    _showSettingsSheet(
      context,
      title: 'Appearance',
      child: Column(
        children: [
          for (final (index, option) in const [
            (ThemeMode.system, 'System'),
            (ThemeMode.light, 'Light'),
            (ThemeMode.dark, 'Dark'),
          ].indexed)
            _SettingsRow(
              icon: current == option.$1
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              label: option.$2,
              chevron: false,
              divider: index > 0,
              onTap: () {
                ref.read(themeModeProvider.notifier).setThemeMode(option.$1);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }

  void _openWeekStartSheet(
    BuildContext context,
    WidgetRef ref,
    WeekStart current,
  ) {
    _showSettingsSheet(
      context,
      title: 'Week starts on',
      child: Column(
        children: [
          for (final (index, option) in WeekStart.values.indexed)
            _SettingsRow(
              icon: current == option
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              label: option.label,
              chevron: false,
              divider: index > 0,
              onTap: () {
                ref.read(weekStartProvider.notifier).setWeekStart(option);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }

  Future<void> _pickDefaultReminderTime(
    BuildContext context,
    WidgetRef ref,
    TimeOfDay current,
  ) async {
    final picked = await pickTime(context, current);
    if (picked != null) {
      ref.read(defaultReminderTimeProvider.notifier).setTime(picked);
    }
  }

  void _openEditProfile(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    _showSettingsSheet(
      context,
      title: 'Edit profile',
      child: _EditProfileSheetContent(controller: controller),
    );
  }

  //   Future<void> _confirmDeleteAccount(
  //     BuildContext context,
  //     WidgetRef ref,
  //   ) async {
  //     final confirmed = await showDialog<bool>(
  //       context: context,
  //       builder: (dialogContext) => AlertDialog(
  //         backgroundColor: ColorPicker.white,
  //         title: const Text('Delete account'),
  //         content: const Text(
  //           'This permanently deletes your account and all your habits. This cannot be undone.',
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(dialogContext).pop(false),
  //             child: const Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () => Navigator.of(dialogContext).pop(true),
  //             style: TextButton.styleFrom(foregroundColor: ColorPicker.danger),
  //             child: const Text('Delete'),
  //           ),
  //         ],
  //       ),
  //     );

  //     if (confirmed != true || !context.mounted) return;

  //     final messenger = ScaffoldMessenger.of(context);
  //     try {
  //       await ref.read(authServiceProvider).deleteAccount();
  //     } catch (_) {
  //       messenger.showSnackBar(
  //         const SnackBar(content: Text('Something went wrong. Try again')),
  //       );
  //     }
  //   }
  // }
  // Future<void> _confirmDeleteAccount(
  //   BuildContext context,
  //   WidgetRef ref,
  // ) async {
  //   final dark = Theme.of(context).brightness == Brightness.dark;

  //   final confirmed = await showDialog<bool>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (dialogContext) {
  //       var isDeleting = false;

  //       // ------------- StatefulBuilder gives the dialog its own setState,
  //       // so we can swap the buttons for a spinner without making the whole
  //       // settings screen rebuild.
  //       return StatefulBuilder(
  //         builder: (context, setDialogState) => PopScope(
  //           // Blocks the Android back button while deleting
  //           canPop: !isDeleting,
  //           child: AlertDialog(
  //             backgroundColor: dark
  //                 ? ColorPicker.darkSurfaceCard
  //                 : ColorPicker.white,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(20),
  //             ),
  //             icon: Container(
  //               width: 56,
  //               height: 56,
  //               decoration: BoxDecoration(
  //                 shape: BoxShape.circle,
  //                 color: ColorPicker.danger.withValues(alpha: 0.12),
  //               ),
  //               child: const Icon(
  //                 Icons.delete_outline_rounded,
  //                 size: 28,
  //                 color: ColorPicker.danger,
  //               ),
  //             ),
  //             title: Text(
  //               'Delete account?',
  //               textAlign: TextAlign.center,
  //               style: context.screenTitle.copyWith(fontSize: 20),
  //             ),
  //             content: Text(
  //               'This permanently deletes your account and all your habits. This cannot be undone.',
  //               textAlign: TextAlign.center,
  //               style: context.body.copyWith(
  //                 fontSize: 15,
  //                 color: dark ? ColorPicker.darkTextMuted : ColorPicker.ink500,
  //               ),
  //             ),
  //             actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
  //             actions: [
  //               Row(
  //                 children: [
  //                   Expanded(
  //                     child: OutlinedButton(
  //                       // null disables the button while deleting
  //                       onPressed: isDeleting
  //                           ? null
  //                           : () => Navigator.of(dialogContext).pop(),
  //                       style: OutlinedButton.styleFrom(
  //                         minimumSize: const Size.fromHeight(44),
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(12),
  //                         ),
  //                       ),
  //                       child: const Text('Cancel'),
  //                     ),
  //                   ),
  //                   const SizedBox(width: 12),
  //                   Expanded(
  //                     child: ElevatedButton(
  //                       onPressed: isDeleting
  //                           ? null
  //                           : () async {
  //                               setDialogState(() => isDeleting = true);
  //                               try {
  //                                 await authService.deleteAccount();
  //                                 // Success: close the dialog. The auth event
  //                                 // will make the router send them to login.
  //                                 if (dialogContext.mounted) {
  //                                   Navigator.of(dialogContext).pop();
  //                                 }
  //                               } catch (_) {
  //                                 // Failure: re-enable the buttons and tell
  //                                 // the user, so they can retry or cancel.
  //                                 if (dialogContext.mounted) {
  //                                   setDialogState(() => isDeleting = false);
  //                                 }
  //                                 messenger.showSnackBar(
  //                                   const SnackBar(
  //                                     content: Text(
  //                                       'Something went wrong. Try again',
  //                                     ),
  //                                   ),
  //                                 );
  //                               }
  //                             },
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: ColorPicker.danger,
  //                         foregroundColor: Colors.white,
  //                         elevation: 0,
  //                         minimumSize: const Size.fromHeight(44),
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(12),
  //                         ),
  //                       ),
  //                       child: isDeleting
  //                           ? const SizedBox(
  //                               width: 20,
  //                               height: 20,
  //                               child: CircularProgressIndicator(
  //                                 strokeWidth: 2,
  //                                 color: Colors.white,
  //                               ),
  //                             )
  //                           : const Text('Delete'),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );

  //   if (confirmed != true || !context.mounted) return;

  //   final messenger = ScaffoldMessenger.of(context);
  //   try {
  //     await ref.read(authServiceProvider).deleteAccount();
  //   } catch (_) {
  //     messenger.showSnackBar(
  //       const SnackBar(content: Text('Something went wrong. Try again')),
  //     );
  //   }
  // }
  Future<void> _confirmDeleteAccount(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final dark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: dark ? ColorPicker.darkSurfaceCard : ColorPicker.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorPicker.danger.withValues(alpha: 0.12),
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            size: 28,
            color: ColorPicker.danger,
          ),
        ),
        // -------------
        title: Text(
          'Delete account?',
          textAlign: TextAlign.center,
          style: context.screenTitle.copyWith(fontSize: 20),
        ),
        content: Text(
          'This permanently deletes your account and all your habits. This cannot be undone.',
          textAlign: TextAlign.center,
          style: context.body.copyWith(
            fontSize: 15,
            color: dark ? ColorPicker.darkTextMuted : ColorPicker.ink500,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPicker.danger,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Delete'),
                ),
              ),
            ],
          ),
        ],
        // -------------
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(authServiceProvider).deleteAccount();
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Something went wrong. Try again')),
      );
    }
  }
}

Future<T?> _showSettingsSheet<T>(
  BuildContext context, {
  required String title,
  required Widget child,
}) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  final sheetBg = dark ? ColorPicker.darkSurfaceCardStrong : ColorPicker.white;
  final handleColor = dark ? ColorPicker.darkBorderDefault : ColorPicker.ink200;
  final titleColor = dark ? ColorPicker.darkTextTitle : ColorPicker.ink900;

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: sheetBg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: handleColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  title,
                  style: sheetContext.sectionTitle.copyWith(
                    fontSize: 18,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 8),
                child,
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final faintColor = dark ? ColorPicker.darkTextFaint : ColorPicker.ink400;
    final cardColor = dark ? ColorPicker.darkSurfaceCard : ColorPicker.white;
    final borderColor = dark
        ? ColorPicker.darkBorderSubtle
        : ColorPicker.ink100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            title.toUpperCase(),
            style: context.small.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 0.44,
              color: faintColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 0.75),
            boxShadow: dark
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFF101620).withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                    BoxShadow(
                      color: const Color(0xFF101620).withValues(alpha: 0.04),
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
    this.control,
    this.divider = false,
    this.chevron = true,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final Widget? control;
  final bool divider;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = dark ? ColorPicker.darkTextMuted : ColorPicker.ink500;
    final faintColor = dark ? ColorPicker.darkTextFaint : ColorPicker.ink400;
    final titleColor = dark ? ColorPicker.darkTextTitle : ColorPicker.ink900;
    final dividerColor = dark
        ? ColorPicker.darkBorderSubtle
        : ColorPicker.ink100;

    return InkWell(
      onTap: control == null ? onTap : null,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: divider ? Border(top: BorderSide(color: dividerColor)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: mutedColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: context.body.copyWith(fontSize: 15, color: titleColor),
              ),
            ),
            if (control != null)
              control!
            else ...[
              if (value != null)
                Text(
                  value!,
                  style: context.small.copyWith(
                    fontSize: 14,
                    color: mutedColor,
                  ),
                ),
              if (onTap != null && chevron) ...[
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, size: 20, color: faintColor),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _EditProfileSheetContent extends StatefulWidget {
  const _EditProfileSheetContent({required this.controller});

  final TextEditingController controller;

  @override
  State<_EditProfileSheetContent> createState() =>
      _EditProfileSheetContentState();
}

class _EditProfileSheetContentState extends State<_EditProfileSheetContent> {
  var _isSaving = false;

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSaving = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'name': widget.controller.text.trim()}),
      );
      navigator.pop();
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Something went wrong. Try again')),
      );
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: widget.controller,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Your name'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? ColorPicker.darkActionQuiet
                  : ColorPicker.ink900,
              foregroundColor: ColorPicker.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save'),
          ),
        ),
      ],
    );
  }
}
