import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';

/// A circular avatar displaying the authenticated user's profile photo,
/// or a fallback account icon if no photo is available.
class UserAvatar extends StatelessWidget {
  /// The diameter of the avatar.
  final double size;

  const UserAvatar({super.key, this.size = 80.0});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final photoURL = authService.currentUser?.photoURL;
    final theme = Theme.of(context);

    if (photoURL != null && photoURL.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.network(
          photoURL,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _fallbackIcon(theme),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: size,
              height: size,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
        ),
      );
    }

    return _fallbackIcon(theme);
  }

  Widget _fallbackIcon(ThemeData theme) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primaryContainer,
      ),
      child: Icon(
        Symbols.account_circle_filled,
        size: size * 0.7,
        color: theme.colorScheme.onPrimaryContainer,
      ),
    );
  }
}
