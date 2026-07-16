import 'dart:async';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter/controllers/profile_screen_controller.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/services/in_app_review_service.dart';

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
                style: const TextStyle(color: Colors.red),
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
    final displayName = authService.currentUser?.displayName ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(l10n.profilePageTitle),
      ),
      body: SafeArea(
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
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
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
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          iconColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (controller.isLoading)
              const ModalBarrier(
                dismissible: false,
                color: Colors.black26,
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
