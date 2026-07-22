import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/routing/app_routes.dart';

class RouterGeneratorConfig {
  static GoRouter goRouter = GoRouter(
    initialLocation: AppRoutes.splashScreen,
    errorBuilder: (context, state) => const NotFoundScreen(),

    routes: [
      // GoRoute(
      //   path: AppRoutes.splashScreen,
      //   name: AppRoutes.splashScreen,
      //   builder: (context, state) => const SplashScreen(),
      // ),
    ],
  );
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Page not found")));
  }
}
