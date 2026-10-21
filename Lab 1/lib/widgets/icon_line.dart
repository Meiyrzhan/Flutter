import 'package:flutter/material.dart';

/// An icon, a title and an optional subtitle in one row.
/// With [highlighted] the row gets the primary container colour and a bold
/// title (used for "You" in the readers list).
class IconLine extends StatelessWidget {
  const IconLine({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.highlighted = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final subtitle = this.subtitle;
    final foreground = highlighted ? scheme.onPrimaryContainer : null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlighted ? scheme.primaryContainer : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: foreground),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: foreground,
                      fontWeight: highlighted ? FontWeight.bold : null,
                    ),
                  ),
                  if (subtitle != null)
                    Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
