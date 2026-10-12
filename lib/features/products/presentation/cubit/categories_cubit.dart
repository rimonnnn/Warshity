import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/features/products/data/models/category_model.dart';
import 'package:warshity/features/products/data/repo/categories_repository.dart';
import 'package:warshity/features/products/presentation/cubit/categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final CategoriesRepository repository;

  StreamSubscription<List<CategoryModel>>? _subscription;

  CategoriesCubit(this.repository) : super(CategoriesInitial());

  // ============================================================
  // Watch Categories
  // ============================================================

  void watchCategories() {
    emit(CategoriesLoading());

    _subscription?.cancel();

    _subscription = repository.watchCategories().listen(
      (categories) {
        emit(CategoriesLoaded(categories));
      },
      onError: (error) {
        emit(CategoriesError(error.toString()));
      },
    );
  }

  // ============================================================
  // Helpers
  // ============================================================

  List<CategoryModel> _currentCategories() {
    final s = state;
    if (s is CategoriesLoaded) return s.categories;
    if (s is AddCategoryLoading) return s.categories;
    if (s is AddCategoryError) return s.categories;
    return const [];
  }

  // ============================================================
  // Add Category
  // ============================================================

  Future<void> addCategory(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return;

    final currentCategories = _currentCategories();

    final exists = currentCategories.any(
      (c) => c.name.toLowerCase() == trimmedName.toLowerCase(),
    );
    if (exists) {
      emit(AddCategoryError(currentCategories, 'Category already exists'));
      return;
    }

    emit(AddCategoryLoading(currentCategories));

    try {
      await repository.addCategory(trimmedName);

      // الـ snapshot غالبًا سبق وعمل CategoriesLoaded بالقايمة الجديدة.
      // لو لسه، نخرج من حالة الـ loading عشان ما نفضلش عالقين.
      if (state is AddCategoryLoading) {
        emit(CategoriesLoaded(currentCategories));
      }
    } catch (e) {
      debugPrint('Add category error: $e');
      emit(
        AddCategoryError(
          currentCategories,
          'Failed to add category. Please try again.',
        ),
      );
    }
  }

  // ============================================================
  // Dispose
  // ============================================================

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}