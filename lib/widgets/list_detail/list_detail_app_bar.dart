import 'package:flutter/material.dart';
import '../common/app_bar_pill_button.dart';

enum ListMenuAction { rename, delete }

class ListDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const ListDetailAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Size get preferredSize => const Size.fromHeight(92);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppBar(
      elevation: 0,
      toolbarHeight: 92,
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: _ListDetailHeader(
        title: title,
        subtitle: subtitle,
        onBack: onBack,
        onRename: onRename,
        onDelete: onDelete,
      ),
    );
  }
}

class _ListDetailHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _ListDetailHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(scheme.primary.withOpacity(0.22), scheme.surface),
            Color.alphaBlend(scheme.primary.withOpacity(0.10), scheme.surface),
            scheme.surface,
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppBarPillButton(
                tooltip: 'Back',
                icon: Icons.arrow_back_ios_new,
                onPressed: onBack,
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface.withOpacity(0.60),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Overflow menu
              PopupMenuButton<ListMenuAction>(
                tooltip: 'More',
                offset: const Offset(0, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onSelected: (action) {
                  switch (action) {
                    case ListMenuAction.rename:
                      onRename();
                      break;
                    case ListMenuAction.delete:
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (ctx) => const [
                  PopupMenuItem(
                    value: ListMenuAction.rename,
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined),
                        SizedBox(width: 10),
                        Text('Rename list'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: ListMenuAction.delete,
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline),
                        SizedBox(width: 10),
                        Text('Delete list'),
                      ],
                    ),
                  ),
                ],
                child: const AppBarPillButton(
                  tooltip: 'More',
                  icon: Icons.more_horiz,
                  onPressed: null, // PopupMenuButton handles taps
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
