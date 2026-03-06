import 'package:flutter/material.dart';
import 'package:grocery_list/screens/edit_display_name_screen.dart';
import 'package:grocery_list/theme/app_colors.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class ProfileDetailsResult {
  const ProfileDetailsResult({
    required this.displayName,
    required this.email,
    required this.avatarBytes,
  });

  final String displayName;
  final String email;
  final Uint8List? avatarBytes;
}

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({
    super.key,
    this.initialAvatarBytes,
    this.initialDisplayName = '',
    this.initialEmail = '',
  });

  final Uint8List? initialAvatarBytes;
  final String initialDisplayName;
  final String initialEmail;

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  late final TextEditingController _displayNameController;
  late final TextEditingController _emailController;
  final ImagePicker _imagePicker = ImagePicker();
  final GlobalKey _displayNameFieldKey = GlobalKey();
  final GlobalKey _emailFieldKey = GlobalKey();
  late final String _initialDisplayName;
  Uint8List? _avatarBytes;
  bool _hasChanges = false;
  bool _isAvatarPressed = false;

  String get _avatarInitials {
    final source = _displayNameController.text.trim();
    if (source.isEmpty) {
      return 'U';
    }
    final parts = source
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'U';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    final first = parts.first.substring(0, 1).toUpperCase();
    final last = parts.last.substring(0, 1).toUpperCase();
    return '$first$last';
  }

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.initialDisplayName,
    );
    _emailController = TextEditingController(text: widget.initialEmail);
    _avatarBytes = widget.initialAvatarBytes;

    _initialDisplayName = _displayNameController.text;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _editDisplayName() async {
    final updatedName = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => EditDisplayNameScreen(
          initialDisplayName: _displayNameController.text.trim(),
        ),
      ),
    );

    if (!mounted || updatedName == null) return;

    final trimmed = updatedName.trim();
    if (trimmed == _displayNameController.text.trim()) return;

    setState(() {
      _displayNameController.text = trimmed;
      _hasChanges = trimmed != _initialDisplayName;
    });
  }

  void _closeProfile() {
    final trimmedDisplayName = _displayNameController.text.trim();
    if (_hasChanges || trimmedDisplayName != _initialDisplayName) {
      Navigator.of(context).pop(
        ProfileDetailsResult(
          displayName: trimmedDisplayName,
          email: _emailController.text.trim(),
          avatarBytes: _avatarBytes,
        ),
      );
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _onAvatarTap() async {
    final source = await _showAvatarSourceSheet();
    if (!mounted || source == null) return;

    final pickedFile = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1600,
    );

    if (!mounted || pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();
    if (!mounted) return;

    setState(() {
      _avatarBytes = bytes;
      _hasChanges = true;
    });
  }

  Future<ImageSource?> _showAvatarSourceSheet() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from library'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a photo'),
                onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _closeProfile();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            onPressed: _closeProfile,
            icon: const Icon(Icons.arrow_back),
          ),
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'Profile',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SafeArea(
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Center(
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: _onAvatarTap,
                    onHighlightChanged: (isHighlighted) {
                      if (_isAvatarPressed == isHighlighted) return;
                      setState(() {
                        _isAvatarPressed = isHighlighted;
                      });
                    },
                    customBorder: const CircleBorder(),
                    splashColor: AppColors.primary.withOpacity(0.12),
                    highlightColor: AppColors.primary.withOpacity(0.08),
                    child: AnimatedScale(
                      scale: _isAvatarPressed ? 0.96 : 1,
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.easeOut,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 52,
                            backgroundColor: AppColors.primary.withOpacity(
                              0.16,
                            ),
                            backgroundImage: _avatarBytes == null
                                ? null
                                : MemoryImage(_avatarBytes!),
                            child: _avatarBytes == null
                                ? Text(
                                    _avatarInitials,
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                : null,
                          ),
                          if (_avatarBytes != null)
                            Positioned.fill(
                              child: ClipOval(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.inputBorder,
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.surface,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 16,
                                color: AppColors.surface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const _SectionLabel(title: 'Personal Information'),
              _GroupedContainer(
                child: Column(
                  children: [
                    _FormFieldTile(
                      fieldKey: _displayNameFieldKey,
                      label: 'Display Name',
                      controller: _displayNameController,
                      readOnly: true,
                      onTap: _editDisplayName,
                      showChevron: true,
                      showLockIcon: false,
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.inputBorderSoft,
                    ),
                    _FormFieldTile(
                      fieldKey: _emailFieldKey,
                      label: 'Email',
                      controller: _emailController,
                      readOnly: true,
                      rowOpacity: 0.74,
                      showLockIcon: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const _SectionLabel(title: 'Account Info'),
              _GroupedContainer(
                child: Column(
                  children: [
                    ListTile(
                      dense: true,
                      minTileHeight: 52,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 2,
                      ),
                      title: Text(
                        'Member Since',
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      trailing: Text(
                        'Jan 2024',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.inputBorderSoft,
                    ),
                    ListTile(
                      dense: true,
                      minTileHeight: 52,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 2,
                      ),
                      title: Text(
                        'Email Verified',
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Yes',
                          style: textTheme.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
      padding: const EdgeInsets.only(left: 4, bottom: 8),
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
  const _GroupedContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _FormFieldTile extends StatelessWidget {
  const _FormFieldTile({
    required this.fieldKey,
    required this.label,
    required this.controller,
    this.readOnly = false,
    this.rowOpacity = 1,
    this.onTap,
    this.showChevron = false,
    this.showLockIcon = true,
  });

  final Key fieldKey;
  final String label;
  final TextEditingController controller;
  final bool readOnly;
  final double rowOpacity;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool showLockIcon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final row = Padding(
      key: fieldKey,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Opacity(
        opacity: rowOpacity,
        child: Row(
          children: [
            SizedBox(
              width: 108,
              child: Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: _InlineField(
                controller: controller,
                readOnly: readOnly,
                isFocused: false,
                textTheme: textTheme,
                showLockIcon: showLockIcon,
              ),
            ),
            if (showChevron)
              Icon(
                Icons.chevron_right,
                size: 18,
                color: Theme.of(context).colorScheme.outline,
              ),
          ],
        ),
      ),
    );

    if (onTap == null) {
      return row;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}

class _InlineField extends StatelessWidget {
  const _InlineField({
    required this.controller,
    required this.readOnly,
    required this.isFocused,
    required this.textTheme,
    this.showLockIcon = true,
  });

  final TextEditingController controller;
  final bool readOnly;
  final bool isFocused;
  final TextTheme textTheme;
  final bool showLockIcon;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isFocused
            ? AppColors.focusGreen.withOpacity(0.08)
            : Colors.transparent,
        border: Border.all(
          color: isFocused
              ? AppColors.focusGreen.withOpacity(0.55)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        enabled: false,
        style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          suffixIcon: readOnly && showLockIcon
              ? const Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: AppColors.textSecondary,
                )
              : null,
        ),
      ),
    );
  }
}
