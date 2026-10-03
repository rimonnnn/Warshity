import 'package:flutter/material.dart';

class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    required this.isMobile,
  });

  final List<Widget> children;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            SizedBox(width: double.infinity, child: children[i]),
            if (i != children.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 4.4,
      children: children,
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
