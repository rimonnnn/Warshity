import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/features/global_search/presentation/cubit/global_search_cubit.dart';
import 'package:warshity/features/global_search/presentation/widgets/global_search_results.dart';
import 'package:warshity/features/home/presentation/layout/web_home.dart';
import 'package:warshity/features/main/presentation/widgets/main_nav_item.dart';
import 'package:warshity/features/main/presentation/widgets/side_bar.dart';
import 'package:warshity/features/main/presentation/widgets/web_top_bar_widget.dart';

class MainWeb extends StatefulWidget {
  const MainWeb({
    super.key,
    required this.navItems,
  });

  final List<MainNavItem> navItems;

  @override
  State<MainWeb> createState() => _MainWebState();
}

class _MainWebState extends State<MainWeb> {
  int _currentIndex = 0;

  void _changeTab(int index) {
    if (index < 0 || index >= widget.navItems.length) return;

    setState(() {
      _currentIndex = index;
    });

    context.read<GlobalSearchCubit>().clear();
  }

  @override
  Widget build(BuildContext context) {
    final screens = widget.navItems.map((item) {
      if (item.screen is WebHome) {
        return WebHome(
          onNavigate: _changeTab,
        );
      }

      return item.screen;
    }).toList();

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: Row(
        children: [
          Sidebar(
            navItems: widget.navItems,
            currentIndex: _currentIndex,
            onSelect: _changeTab,
          ),

          Expanded(
            child: Column(
              children: [
                WebTopBar(
                  onSearchChanged: (value) {
                    context.read<GlobalSearchCubit>().search(value);
                  },
                ),

                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: IndexedStack(
                          index: _currentIndex,
                          children: screens,
                        ),
                      ),

                      if (_currentIndex == 0)
                        const Positioned(
                          top: 16,
                          left: 24,
                          right: 24,
                          child: GlobalSearchResults(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}