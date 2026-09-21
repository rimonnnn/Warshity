import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/features/clients/presentation/cubit/clients_cubit.dart';
import 'package:warshity/features/clients/presentation/screens/cleints_screen.dart';

class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ClientsCubit>()..watchClients(),
      child: const CleintsScreen(),
    );
  }
}
