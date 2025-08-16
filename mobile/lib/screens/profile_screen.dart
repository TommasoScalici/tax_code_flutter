import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _showDeleteUserConfirmDialog(BuildContext context) async {
    final authService = context.read<AuthService>();
    final l10n = AppLocalizations.of(context)!;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteConfirmation),
          content: Text(l10n.deleteAccountMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await authService.deleteUserAccount();
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                } catch (e) {
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text(l10n.genericError)),
                  );
                }
              },
              child: Text(
                l10n.delete,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final l10n = AppLocalizations.of(context)!;
    final displayName = authService.currentUser?.displayName ?? '';
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(l10n.profilePageTitle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const UserAvatar(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(displayName, style: const TextStyle(fontSize: 24)),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await authService.signOut();
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text(l10n.genericError)),
                      );
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: Text(l10n.signOut),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showDeleteUserConfirmDialog(context),
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
              )
            ],
          ),
        ),
      ),
    );
  }
}