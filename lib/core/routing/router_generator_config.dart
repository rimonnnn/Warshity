import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/features/auth/register/presentation/cubit/auth_cubit.dart';
import 'package:warshity/features/auth/register/presentation/screens/register_screen.dart';

class RouterGeneratorConfig {
  static GoRouter goRouter = GoRouter(
    initialLocation: AppRoutes.signUpScreen,
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      GoRoute(
        path: AppRoutes.signUpScreen,
        name: AppRoutes.signUpScreen,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<AuthCubit>(),
          child: const RegisterScreen(),
        ),
      ),
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
