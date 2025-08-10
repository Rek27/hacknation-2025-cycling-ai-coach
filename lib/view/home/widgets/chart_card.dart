import 'package:flutter/material.dart';
import 'package:hackathon/themes/app_constants.dart';

class ChartCard extends StatelessWidget {
  const ChartCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.chartHeight = 200,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final double chartHeight;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.onSurface,
          width: BorderWidth.m,
        ),
        borderRadius: BorderRadius.circular(Radiuses.s),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacings.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            if (subtitle != null) ...[
              Text(subtitle!, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: Spacings.xl),
            SizedBox(height: chartHeight, child: child),
          ],
        ),
      ),
    );
  }
}
