import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/features/auth/cubit/auth_cubit.dart';
import 'package:warshity/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:warshity/features/settings/presentation/screens/settings_screen.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
         BlocProvider(
        create: (_) => getIt<SettingsCubit>(),
        child: const SettingsScreen(),
      ),
      BlocProvider(create: (_) => getIt<AuthCubit>())
      ],
      child: const SettingsScreen(),
      
    );
  }
}
