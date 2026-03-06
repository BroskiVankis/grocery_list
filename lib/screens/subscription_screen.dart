import 'package:flutter/material.dart';
import 'package:grocery_list/theme/app_colors.dart';

enum PricingPlan { monthly, yearly }

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  PricingPlan _selectedPlan = PricingPlan.yearly;

  String get _ctaPriceText {
    if (_selectedPlan == PricingPlan.monthly) {
      return r'$3.99/month';
    }
    return r'$24.99/year';
  }

  String get _ctaButtonText {
    return 'Start 3-Day Free Trial then $_ctaPriceText';
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
          'Subscription',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
        children: [
          const Text(
            'Upgrade to Pro',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Unlock powerful features',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),
          _SectionHeader(title: 'Pro Features', colorScheme: colorScheme),
          _SectionCard(
            child: Column(
              children: const [
                _FeatureTile(
                  text: 'Add recipe ingredients directly to grocery list',
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.inputBorderSoft,
                ),
                _FeatureTile(text: 'Unlimited meal plans'),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.inputBorderSoft,
                ),
                _FeatureTile(text: 'Smart grocery lists'),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.inputBorderSoft,
                ),
                _FeatureTile(text: 'Import recipes'),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.inputBorderSoft,
                ),
                _FeatureTile(text: 'Nutrition information'),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.inputBorderSoft,
                ),
                _FeatureTile(text: 'Cloud sync'),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.inputBorderSoft,
                ),
                _FeatureTile(text: 'Access to all future Pro features'),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _SectionHeader(title: 'Pricing Options', colorScheme: colorScheme),
          Column(
            children: [
              _PricingOptionTile(
                title: 'Monthly plan',
                price: '\$3.99 / month',
                selected: _selectedPlan == PricingPlan.monthly,
                onTap: () {
                  setState(() {
                    _selectedPlan = PricingPlan.monthly;
                  });
                },
              ),
              const SizedBox(height: 10),
              _PricingOptionTile(
                title: 'Yearly plan',
                price: '\$24.99 / year',
                secondaryLine: 'Save 48%',
                selected: _selectedPlan == PricingPlan.yearly,
                badge: 'Best Value',
                onTap: () {
                  setState(() {
                    _selectedPlan = PricingPlan.yearly;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: AppColors.background,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ctaGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {},
                  child: Text(
                    _ctaButtonText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Cancel anytime. Payment handled securely by the App Store.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final ColorScheme colorScheme;

  const _SectionHeader({required this.title, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          letterSpacing: 1.1,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

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

class _FeatureTile extends StatelessWidget {
  final String text;

  const _FeatureTile({required this.text});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      minTileHeight: 48,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: const Icon(
        Icons.check_circle_outline,
        color: AppColors.brandGreen,
      ),
      title: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}

class _PricingOptionTile extends StatelessWidget {
  final String title;
  final String price;
  final String? secondaryLine;
  final bool selected;
  final String? badge;
  final VoidCallback onTap;

  const _PricingOptionTile({
    required this.title,
    required this.price,
    this.secondaryLine,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary.withOpacity(0.05)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.inputBorder,
          width: selected ? 1.4 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: ListTile(
            dense: true,
            minTileHeight: 56,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 2,
            ),
            title: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        price,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (secondaryLine != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          secondaryLine!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.brandGreen,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (badge != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.brandGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          color: AppColors.brandGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            trailing: Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off_outlined,
              color: selected ? AppColors.brandGreen : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
