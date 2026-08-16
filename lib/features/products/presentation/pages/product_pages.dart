import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/features/products/presentation/cubit/products_cubit.dart';
import 'package:warshity/features/products/presentation/screens/product_screen.dart';

class ProductPages extends StatelessWidget {
  const ProductPages({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProductsCubit>()..watchProducts(),
      child: const ProductScreen(),
    );
  }
}
