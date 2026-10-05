import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/widgets/app_responsive.dart';
import 'package:warshity/features/clients/data/repo/clients_reprosatory.dart';
import 'package:warshity/features/clients/presentation/cubit/clients_cubit.dart';
import 'package:warshity/features/clients/presentation/layout/mobile_client.dart';
import 'package:warshity/features/clients/presentation/layout/web_client.dart';

class CleintsScreen extends StatelessWidget {
  const CleintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = ClientsCubit(getIt<ClientsRepository>());

        cubit.watchClients();

        return cubit;
      },
      child: Scaffold(
        body: AppResponsive(mobile: MobileClient(), desktop: WebCustomers()),
      ),
    );
  }
}
