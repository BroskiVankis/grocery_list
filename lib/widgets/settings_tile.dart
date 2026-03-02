import 'package:flutter/material.dart';
import 'package:grocery_list/theme/app_colors.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    const borderRadius = BorderRadius.all(Radius.circular(12));

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        splashColor: AppColors.brandGreen.withOpacity(0.08),
        highlightColor: Colors.transparent,
        child: ListTile(
          dense: true,
          minTileHeight: 48,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 2,
          ),
          leading: Icon(icon, size: 20, color: AppColors.brandGreen),
          title: Text(
            title,
            style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
          ),
          trailing: Icon(
            Icons.chevron_right,
            size: 18,
            color: colorScheme.outline,
          ),
        ),
      ),
    );
  }
}
