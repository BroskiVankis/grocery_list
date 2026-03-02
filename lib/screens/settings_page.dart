import 'package:flutter/material.dart';
import 'package:grocery_list/models/settings_item.dart';
import 'package:grocery_list/theme/app_colors.dart';
import 'package:grocery_list/widgets/settings_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final List<SettingsItem> _items;
  late final List<List<SettingsItem>> _groups;
  late final List<String> _groupHeaders;

  @override
  void initState() {
    super.initState();
    _items = SettingsItem.defaultItems;
    _groups = [_items.sublist(0, 4), _items.sublist(4, 7), _items.sublist(7)];
    _groupHeaders = ['Preferences', 'Support', 'About'];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: Navigator.canPop(context),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.only(top: 12, bottom: 12),
          itemCount: _groups.length,
          itemBuilder: (context, groupIndex) {
            final group = _groups[groupIndex];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 8),
                  child: Text(
                    _groupHeaders[groupIndex].toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.1,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (
                        var rowIndex = 0;
                        rowIndex < group.length;
                        rowIndex++
                      ) ...[
                        ColoredBox(
                          color: groupIndex == 0 && rowIndex == 0
                              ? AppColors.primary.withOpacity(0.05)
                              : Colors.transparent,
                          child: SettingsTile(
                            icon: group[rowIndex].icon,
                            title: group[rowIndex].title,
                            onTap: () => Navigator.pushNamed(
                              context,
                              group[rowIndex].route,
                            ),
                          ),
                        ),
                        if (rowIndex != group.length - 1)
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.inputBorderSoft,
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 24),
        ),
      ),
    );
  }
}
