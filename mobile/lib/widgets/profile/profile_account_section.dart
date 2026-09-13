import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter/controllers/profile_screen_controller.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'profile_action_tile.dart';

/// The account management and GDPR account deletion section.
class ProfileAccountSection extends StatelessWidget {
  const ProfileAccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<ProfileScreenController?>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionHeader(
          title: l10n?.sectionAccountManagement.toUpperCase() ??
              'GESTIONE ACCOUNT',
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              ProfileActionTile(
                key: const Key('profile_sign_out_tile'),
                icon: Icons.logout_rounded,
                iconColor: theme.colorScheme.onSurfaceVariant,
                iconBgColor: theme.colorScheme.surfaceContainerHigh,
                title: l10n?.signOut ?? "Esci dall'account",
                subtitle: l10n?.signOutSubtitle ??
                    'Scollega il profilo Google da questo dispositivo',
                onTap: controller?.isLoading == true
                    ? null
                    : () => _handleSignOut(context, controller),
              ),
              const ProfileCardDivider(),
              ProfileActionTile(
                key: const Key('profile_delete_account_tile'),
                icon: Icons.delete_forever_rounded,
                iconColor: theme.colorScheme.error,
                iconBgColor: theme.colorScheme.errorContainer,
                title: l10n?.deleteAccount ?? 'Elimina account e dati',
                titleColor: theme.colorScheme.error,
                subtitle: l10n?.deleteAccountGdprSubtitle ??
                    "Cancellazione definitiva e diritto all'oblio (GDPR)",
                onTap: controller?.isLoading == true
                    ? null
                    : () => _handleDeleteAccount(context, controller),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleSignOut(
    BuildContext context,
    ProfileScreenController? controller,
  ) async {
    final authService = context.read<AuthService?>();
    if (controller != null) {
      await controller.signOut();
    } else if (authService != null) {
      await authService.signOut();
    }
    if (context.mounted) {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _handleDeleteAccount(
    BuildContext context,
    ProfileScreenController? controller,
  ) async {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          l10n?.deleteConfirmation ?? 'Conferma Eliminazione',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          l10n?.deleteAccountMessage ??
              'Sei sicuro di voler eliminare definitivamente il tuo account? Questa azione è irreversibile e comporterà la cancellazione di tutti i codici fiscali sincronizzati.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(l10n?.cancel ?? 'Annulla'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(l10n?.delete ?? 'Elimina'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authService = context.read<AuthService?>();
      if (controller != null) {
        await controller.deleteAccount(
          onPromptReauth: () async => false,
        );
      } else if (authService != null) {
        await authService.deleteUserAccount();
      }
      if (context.mounted) {
        Navigator.of(context).maybePop();
      }
    }
  }
}
