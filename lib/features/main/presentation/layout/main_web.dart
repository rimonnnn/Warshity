import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/main/presentation/widgets/main_nav_item.dart';
import 'package:warshity/features/main/presentation/widgets/side_bar.dart';

class MainWeb extends StatefulWidget {
  const MainWeb({super.key, required this.navItems});

  final List<MainNavItem> navItems;

  @override
  State<MainWeb> createState() => _MainWebState();
}

class _MainWebState extends State<MainWeb> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: Row(
        children: [
          Sidebar(
            navItems: widget.navItems,
            currentIndex: _currentIndex,
            onSelect: (index) => setState(() => _currentIndex = index),
          ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: widget.navItems.map((item) => item.screen).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
