import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';

/// An interactive list tile adhering to the Stitch grouped card container style.
class ProfileActionTile extends StatelessWidget {
  /// Icon displayed on the leading side.
  final IconData icon;

  /// Foreground color of the leading icon.
  final Color iconColor;

  /// Background color of the rounded icon badge container.
  final Color iconBgColor;

  /// Primary action title text.
  final String title;

  /// Optional custom title text color (e.g. for destructive actions).
  final Color? titleColor;

  /// Optional subtitle text displayed below the title.
  final String? subtitle;

  /// Trailing widget (typically a chevron or external link icon).
  final Widget? trailing;

  /// Callback executed when tapping the tile. Disabled when null.
  final VoidCallback? onTap;

  const ProfileActionTile({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    super.key,
    this.titleColor,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onTap != null;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              // Icon with rounded container badge
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 20),
                ),
              ),
              const SizedBox(width: 14),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isEnabled
                            ? (titleColor ?? theme.colorScheme.onSurface)
                            : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isEnabled
                              ? theme.colorScheme.onSurfaceVariant
                              : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing widget
              if (trailing != null) ...[
                const SizedBox(width: 8),
                IconTheme(
                  data: IconThemeData(
                    color: isEnabled
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
                    size: 18,
                  ),
                  child: trailing!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A section header label formatted with uppercase small typography.
class ProfileSectionHeader extends StatelessWidget {
  final String title;

  const ProfileSectionHeader({
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 2.0),
      child: Text(
        title,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// A subtle horizontal divider used within grouped card containers.
class ProfileCardDivider extends StatelessWidget {
  const ProfileCardDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Divider(
      height: 1,
      thickness: 1,
      indent: 68,
      endIndent: 16,
      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
    );
  }
}
