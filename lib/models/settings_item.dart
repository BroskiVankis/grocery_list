import 'package:flutter/material.dart';

class SettingsItem {
  final String title;
  final IconData icon;
  final String route;

  const SettingsItem({
    required this.title,
    required this.icon,
    required this.route,
  });

  static final List<SettingsItem> defaultItems = [
    const SettingsItem(
      title: 'Food Preferences',
      icon: Icons.tune,
      route: '/food-preferences',
    ),
    const SettingsItem(
      title: 'Your Recipes',
      icon: Icons.menu_book_outlined,
      route: '/your-recipes',
    ),
    const SettingsItem(
      title: 'Account',
      icon: Icons.person_outline,
      route: '/account',
    ),
    const SettingsItem(
      title: 'Subscription',
      icon: Icons.workspace_premium_outlined,
      route: '/subscription',
    ),
    const SettingsItem(
      title: 'Help Improve App',
      icon: Icons.lightbulb_outline,
      route: '/help-improve-app',
    ),
    const SettingsItem(
      title: 'Support Center',
      icon: Icons.support_agent_outlined,
      route: '/support-center',
    ),
    const SettingsItem(
      title: 'Reminders',
      icon: Icons.notifications_outlined,
      route: '/reminders',
    ),
    const SettingsItem(
      title: 'Contact Us',
      icon: Icons.mail_outline,
      route: '/contact-us',
    ),
    const SettingsItem(
      title: 'Share App',
      icon: Icons.share_outlined,
      route: '/share-app',
    ),
    const SettingsItem(
      title: 'Rate App',
      icon: Icons.star_outline,
      route: '/rate-app',
    ),
    const SettingsItem(
      title: 'About',
      icon: Icons.info_outline,
      route: '/about',
    ),
  ];
}
