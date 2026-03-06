import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:grocery_list/screens/change_password_screen.dart';
import 'package:grocery_list/screens/connected_accounts_screen.dart';
import 'package:grocery_list/screens/login_page.dart';
import 'package:grocery_list/screens/profile_details_screen.dart';
import 'package:grocery_list/state/units_preference.dart';
import 'package:grocery_list/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _notificationsEnabled = true;
  String _displayName = '';
  String _email = '';
  Uint8List? _avatarBytes;

  String get _resolvedDisplayName {
    if (_displayName.trim().isNotEmpty) {
      return _displayName.trim();
    }
    final email = _email.trim();
    if (email.contains('@')) {
      return email.split('@').first;
    }
    return email.isNotEmpty ? email : 'User';
  }

  String get _avatarInitials {
    final source = _resolvedDisplayName.trim();
    if (source.isEmpty) return 'U';
    final parts = source.split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
    if (parts.isEmpty) return 'U';
    final list = parts.toList();
    if (list.length == 1) {
      return list.first.substring(0, 1).toUpperCase();
    }
    final first = list.first.substring(0, 1).toUpperCase();
    final last = list.last.substring(0, 1).toUpperCase();
    return '$first$last';
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = (prefs.getString('local_user_email') ?? '').trim();
    final storedDisplayName = (prefs.getString('local_user_display_name') ?? '')
        .trim();
    final storedUsername = (prefs.getString('local_user_username') ?? '')
        .trim();
    final storedAvatarBase64 = prefs.getString('local_user_avatar_base64');

    final fallbackDisplayName = storedUsername.isNotEmpty
        ? storedUsername
        : (storedEmail.contains('@') ? storedEmail.split('@').first : '');

    Uint8List? resolvedAvatar;
    if (storedAvatarBase64 != null && storedAvatarBase64.isNotEmpty) {
      try {
        resolvedAvatar = base64Decode(storedAvatarBase64);
      } catch (_) {
        resolvedAvatar = null;
      }
    }

    if (!mounted) return;
    setState(() {
      _displayName = storedDisplayName.isNotEmpty
          ? storedDisplayName
          : fallbackDisplayName;
      _email = storedEmail;
      _avatarBytes = resolvedAvatar;
    });
  }

  Future<void> _persistUserProfile({
    required String displayName,
    required String email,
    required Uint8List? avatarBytes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('local_user_display_name', displayName.trim());
    await prefs.setString('local_user_email', email.trim().toLowerCase());
    await prefs.setString('local_user_username', displayName.trim());

    if (avatarBytes == null) {
      await prefs.remove('local_user_avatar_base64');
    } else {
      await prefs.setString(
        'local_user_avatar_base64',
        base64Encode(avatarBytes),
      );
    }
  }

  Future<void> _navigateToLogin() async {
    if (!mounted) return;
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Sign Out',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Are you sure you want to sign out?',
            style: TextStyle(color: AppColors.textSecondary, height: 1.35),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged_in', false);

    await _navigateToLogin();
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Account',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'This will permanently delete your account and all recipes, meal plans, and grocery lists. This action cannot be undone.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.35),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete Account'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('local_user_username');
    await prefs.remove('local_user_display_name');
    await prefs.remove('local_user_first_name');
    await prefs.remove('local_user_last_name');
    await prefs.remove('local_user_avatar_base64');
    await prefs.remove('local_user_email');
    await prefs.remove('local_user_salt');
    await prefs.remove('local_user_hash');
    await prefs.setBool('logged_in', false);

    await _navigateToLogin();
  }

  @override
  Widget build(BuildContext context) {
    final unitsController = UnitsPreferenceScope.of(context);
    final currentUnits = unitsController.preference.label;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: Navigator.canPop(context),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Account',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: _LoggedInView(
          onEditProfile: () async {
            final result = await Navigator.of(context)
                .push<ProfileDetailsResult>(
                  MaterialPageRoute<ProfileDetailsResult>(
                    builder: (_) => ProfileDetailsScreen(
                      initialAvatarBytes: _avatarBytes,
                      initialDisplayName: _resolvedDisplayName,
                      initialEmail: _email,
                    ),
                  ),
                );

            if (!mounted || result == null) return;

            await _persistUserProfile(
              displayName: result.displayName,
              email: result.email,
              avatarBytes: result.avatarBytes,
            );

            if (!mounted) return;
            setState(() {
              _displayName = result.displayName;
              _email = result.email;
              _avatarBytes = result.avatarBytes;
            });
          },
          displayName: _resolvedDisplayName,
          email: _email,
          avatarBytes: _avatarBytes,
          avatarInitials: _avatarInitials,
          onConnectedAccounts: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ConnectedAccountsScreen(),
              ),
            );
          },
          onChangePassword: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ChangePasswordScreen(),
              ),
            );
          },
          units: currentUnits,
          onUnitsChanged: (value) async {
            final selectedPreference = UnitsPreferenceLabel.fromLabel(value);
            if (selectedPreference == unitsController.preference) {
              return;
            }
            await unitsController.setPreference(selectedPreference);
            if (!mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Units updated')));
          },
          notificationsEnabled: _notificationsEnabled,
          onNotificationsChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
          },
          onDeleteAccount: () {
            _handleDeleteAccount();
          },
          onSignOut: () {
            _handleSignOut();
          },
        ),
      ),
    );
  }
}

class _LoggedInView extends StatelessWidget {
  const _LoggedInView({
    required this.onEditProfile,
    required this.displayName,
    required this.email,
    required this.avatarBytes,
    required this.avatarInitials,
    required this.onConnectedAccounts,
    required this.onChangePassword,
    required this.units,
    required this.onUnitsChanged,
    required this.notificationsEnabled,
    required this.onNotificationsChanged,
    required this.onDeleteAccount,
    required this.onSignOut,
  });

  final VoidCallback onEditProfile;
  final String displayName;
  final String email;
  final Uint8List? avatarBytes;
  final String avatarInitials;
  final VoidCallback onConnectedAccounts;
  final VoidCallback onChangePassword;
  final String units;
  final ValueChanged<String> onUnitsChanged;
  final bool notificationsEnabled;
  final ValueChanged<bool> onNotificationsChanged;
  final VoidCallback onDeleteAccount;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      key: const ValueKey('loggedInView'),
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.inputBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onEditProfile,
              borderRadius: BorderRadius.circular(16),
              splashColor: AppColors.brandGreen.withOpacity(0.08),
              overlayColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.pressed)) {
                  return AppColors.brandGreen.withOpacity(0.06);
                }
                return null;
              }),
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primary.withOpacity(0.14),
                      backgroundImage: avatarBytes == null
                          ? null
                          : MemoryImage(avatarBytes!),
                      child: avatarBytes == null
                          ? Text(
                              avatarInitials,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: textTheme.titleMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  'Current Plan: Free',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  backgroundColor: AppColors.primary
                                      .withOpacity(0.08),
                                  overlayColor: AppColors.primary.withOpacity(
                                    0.10,
                                  ),
                                  shape: const StadiumBorder(),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  textStyle: textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                onPressed: () {},
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Text('Upgrade to Pro'),
                                    SizedBox(width: 4),
                                    Icon(Icons.arrow_forward_ios, size: 12),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _SectionLabel(title: 'Security'),
        _GroupedContainer(
          children: [
            _ActionTile(
              icon: Icons.link_rounded,
              title: 'Connected Accounts',
              subtitle: 'Google connected • Apple not connected',
              onTap: onConnectedAccounts,
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.inputBorderSoft,
            ),
            _ActionTile(
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: onChangePassword,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SectionLabel(title: 'Preferences'),
        _GroupedContainer(
          children: [
            _UnitsTile(units: units, onUnitsChanged: onUnitsChanged),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.inputBorderSoft,
            ),
            _SwitchTile(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              value: notificationsEnabled,
              onChanged: onNotificationsChanged,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SectionLabel(title: 'Data'),
        _GroupedContainer(
          children: [
            _ActionTile(
              icon: Icons.cloud_outlined,
              title: 'Cloud Sync',
              subtitle: 'Automatic backup enabled',
              showSubtitleStatusDot: true,
              subtitleFontSize: 11,
              showChevron: false,
              onTap: null,
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.inputBorderSoft,
            ),
            _ActionTile(
              icon: Icons.delete_outline,
              title: 'Delete Account',
              onTap: onDeleteAccount,
              isDestructive: true,
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(
            height: 1,
            thickness: 1,
            color: AppColors.inputBorderSoft,
          ),
        ),
        const SizedBox(height: 18),
        _GroupedContainer(
          children: [
            _ActionTile(
              icon: Icons.logout_rounded,
              title: 'Sign Out',
              onTap: onSignOut,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'App Version 1.0.0',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary.withOpacity(0.65),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          letterSpacing: 1.1,
          color: colorScheme.onSurfaceVariant.withOpacity(0.82),
        ),
      ),
    );
  }
}

class _GroupedContainer extends StatelessWidget {
  const _GroupedContainer({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.showSubtitleStatusDot = false,
    this.isDestructive = false,
    this.subtitleFontSize,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final String? subtitle;
  final bool showSubtitleStatusDot;
  final bool isDestructive;
  final double? subtitleFontSize;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final destructiveColor = Theme.of(context).colorScheme.error;
    final titleColor = AppColors.textPrimary;
    final iconColor = isDestructive ? destructiveColor : AppColors.brandGreen;

    final subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: AppColors.textSecondary,
      fontSize: subtitleFontSize,
    );

    final tile = ListTile(
      dense: true,
      minTileHeight: 50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(icon, size: 20, color: iconColor),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: titleColor,
          fontWeight: isDestructive ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : showSubtitleStatusDot
          ? Text.rich(
              TextSpan(
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  TextSpan(text: subtitle!),
                ],
              ),
              style: subtitleStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : Text(subtitle!, style: subtitleStyle),
      trailing: showChevron
          ? Icon(
              Icons.chevron_right,
              size: 18,
              color: Theme.of(context).colorScheme.outline,
            )
          : const SizedBox(width: 18),
    );

    if (onTap == null) {
      return tile;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.brandGreen.withOpacity(0.08),
        highlightColor: Colors.transparent,
        child: tile,
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      minTileHeight: 50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(icon, size: 20, color: AppColors.brandGreen),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
      ),
      trailing: Switch.adaptive(
        value: value,
        activeColor: AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }
}

class _UnitsTile extends StatelessWidget {
  const _UnitsTile({required this.units, required this.onUnitsChanged});

  final String units;
  final ValueChanged<String> onUnitsChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: 58,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: const Icon(
        Icons.straighten_rounded,
        size: 20,
        color: AppColors.brandGreen,
      ),
      title: Text(
        'Units',
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
      ),
      trailing: SegmentedButton<String>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment<String>(value: 'Metric', label: Text('Metric')),
          ButtonSegment<String>(value: 'Imperial', label: Text('Imperial')),
        ],
        selected: <String>{units},
        style: SegmentedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          selectedForegroundColor: AppColors.pressedGreen,
          selectedBackgroundColor: AppColors.primary.withOpacity(0.16),
          side: const BorderSide(color: AppColors.inputBorderSoft),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          textStyle: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        onSelectionChanged: (selected) {
          if (selected.isNotEmpty) {
            onUnitsChanged(selected.first);
          }
        },
      ),
    );
  }
}
