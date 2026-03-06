import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grocery_list/theme/app_colors.dart';

class ConnectedAccountsScreen extends StatefulWidget {
  const ConnectedAccountsScreen({super.key});

  @override
  State<ConnectedAccountsScreen> createState() =>
      _ConnectedAccountsScreenState();
}

class _ConnectedAccountsScreenState extends State<ConnectedAccountsScreen> {
  bool isGoogleConnected = false;
  bool isAppleConnected = false;
  bool isFacebookConnected = false;

  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;
  bool _isFacebookLoading = false;

  bool _isGooglePrimary = true;
  bool _isApplePrimary = false;
  bool _isFacebookPrimary = false;

  Future<void> _connectProvider(String providerName) async {
    setState(() {
      if (providerName == 'Google') {
        _isGoogleLoading = true;
      } else if (providerName == 'Apple') {
        _isAppleLoading = true;
      } else {
        _isFacebookLoading = true;
      }
    });

    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    setState(() {
      if (providerName == 'Google') {
        _isGoogleLoading = false;
        isGoogleConnected = true;
      } else if (providerName == 'Apple') {
        _isAppleLoading = false;
        isAppleConnected = true;
      } else {
        _isFacebookLoading = false;
        isFacebookConnected = true;
      }
    });

    _showMessage('$providerName connected');
  }

  Future<void> _disconnectProvider(String providerName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final textTheme = Theme.of(dialogContext).textTheme;
        return AlertDialog(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Disconnect $providerName?',
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'You can reconnect this provider later.',
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
                shape: const StadiumBorder(),
              ),
              child: const Text('Disconnect'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      if (providerName == 'Google') {
        isGoogleConnected = false;
      } else if (providerName == 'Apple') {
        isAppleConnected = false;
      } else {
        isFacebookConnected = false;
      }
    });

    _showMessage('$providerName disconnected');
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Connected Accounts',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 8),
              child: Text(
                'PROVIDERS',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.1,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.82),
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
                children: [
                  _ProviderTile(
                    icon: SvgPicture.asset(
                      'assets/icons/google_g.svg',
                      width: 21,
                      height: 21,
                    ),
                    providerName: 'Google',
                    connected: isGoogleConnected,
                    connectedEmail: isGoogleConnected
                        ? 'alex.rivera@gmail.com'
                        : null,
                    isPrimary: _isGooglePrimary,
                    loading: _isGoogleLoading,
                    onConnect: () => _connectProvider('Google'),
                    onDisconnect: () => _disconnectProvider('Google'),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.inputBorderSoft,
                  ),
                  _ProviderTile(
                    icon: const Icon(
                      Icons.apple,
                      size: 23,
                      color: Color(0xFF111111),
                    ),
                    providerName: 'Apple',
                    connected: isAppleConnected,
                    connectedEmail: isAppleConnected ? 'alex@icloud.com' : null,
                    isPrimary: _isApplePrimary,
                    loading: _isAppleLoading,
                    onConnect: () => _connectProvider('Apple'),
                    onDisconnect: () => _disconnectProvider('Apple'),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.inputBorderSoft,
                  ),
                  _ProviderTile(
                    icon: const Icon(
                      FontAwesomeIcons.facebookF,
                      size: 23,
                      color: Color(0xFF1877F2),
                    ),
                    providerName: 'Facebook',
                    connected: isFacebookConnected,
                    connectedEmail: isFacebookConnected
                        ? 'alex.rivera@facebook.com'
                        : null,
                    isPrimary: _isFacebookPrimary,
                    loading: _isFacebookLoading,
                    onConnect: () => _connectProvider('Facebook'),
                    onDisconnect: () => _disconnectProvider('Facebook'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderTile extends StatelessWidget {
  const _ProviderTile({
    required this.icon,
    required this.providerName,
    required this.connected,
    required this.connectedEmail,
    required this.isPrimary,
    required this.loading,
    required this.onConnect,
    required this.onDisconnect,
  });

  final Widget icon;
  final String providerName;
  final bool connected;
  final String? connectedEmail;
  final bool isPrimary;
  final bool loading;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final disconnectEnabled = connected && !isPrimary && !loading;
    const disconnectBorderColor = Color(0xFFA9B3AD);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 28, height: 28, child: Center(child: icon)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      providerName,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (connected && isPrimary) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '(Primary)',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.focusGreen,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (!connected) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Not connected',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (connected && (connectedEmail?.isNotEmpty ?? false)) ...[
                  const SizedBox(height: 2),
                  Text(
                    connectedEmail!,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 112,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: connected
                  ? OutlinedButton(
                      key: const ValueKey('disconnectBtn'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        disabledForegroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: disconnectBorderColor),
                        minimumSize: const Size(0, 32),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 0,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: disconnectEnabled ? onDisconnect : null,
                      child: loading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Disconnect'),
                    )
                  : FilledButton(
                      key: const ValueKey('connectBtn'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        minimumSize: const Size(0, 32),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 0,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: loading ? null : onConnect,
                      child: loading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white,
                                ),
                              ),
                            )
                          : const Text('Connect'),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
