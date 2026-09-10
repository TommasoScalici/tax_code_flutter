import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter/controllers/profile_screen_controller.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/services/in_app_review_service.dart';
import 'package:tax_code_flutter/widgets/responsive_layout.dart';
import 'package:tax_code_flutter/widgets/user_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfileScreenController(
        authService: context.read<AuthService>(),
        logger: context.read<Logger>(),
      ),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final controller = context.read<ProfileScreenController>();
    final authService = context.read<AuthService>();
    final l10n = AppLocalizations.of(context)!;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteConfirmation),
          content: Text(l10n.deleteAccountMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                l10n.delete,
                style: TextStyle(color: Theme.of(dialogContext).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final success = await controller.deleteAccount(
        onPromptReauth: () async {
          return authService.reauthenticateWithGoogle();
        },
      );

      if (success) {
        navigator.popUntil((route) => route.isFirst);
      } else {
        final errorMsg = controller.customErrorMessage ?? l10n.genericError;
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
        controller.clearError();
      }
    }
  }

  Future<void> _handleSignOut(BuildContext context) async {
    final controller = context.read<ProfileScreenController>();
    final l10n = AppLocalizations.of(context)!;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final success = await controller.signOut();
    if (success) {
      navigator.popUntil((route) => route.isFirst);
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(l10n.genericError)),
      );
      controller.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final controller = context.watch<ProfileScreenController>();
    final l10n = AppLocalizations.of(context)!;
    final displayName = authService.isGuest
        ? l10n.guestMode
        : (authService.currentUser?.displayName ?? '');

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profilePageTitle),
      ),
      body: ResponsiveLayout(
        maxWidth: 480.0,
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const UserAvatar(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        displayName,
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                    if (authService.isGuest) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: controller.isLoading
                              ? null
                              : () async {
                                  final success =
                                      await authService.signInWithGoogle();
                                  if (!context.mounted) return;
                                  if (!success &&
                                      authService.errorMessage != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          authService.errorMessage ??
                                              l10n.signInFailed,
                                        ),
                                      ),
                                    );
                                  }
                                },
                          icon: const Icon(Icons.login),
                          label: Text(l10n.continueWithGoogle),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: controller.isLoading ? null : () => _handleSignOut(context),
                        icon: const Icon(Icons.logout),
                        label: Text(l10n.signOut),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          unawaited(
                            context.read<InAppReviewService>().openStoreListing(),
                          );
                        },
                        icon: const Icon(Icons.star_rate_rounded),
                        label: Text(l10n.rateThisApp),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: controller.isLoading ? null : () => _handleDeleteAccount(context),
                        icon: const Icon(Icons.delete),
                        label: Text(
                          l10n.deleteAccount,
                          style: TextStyle(color: colorScheme.onError),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.error,
                          foregroundColor: colorScheme.onError,
                          iconColor: colorScheme.onError,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (controller.isLoading)
              ModalBarrier(
                dismissible: false,
                color: colorScheme.scrim.withValues(alpha: 0.32),
              ),
            if (controller.isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
