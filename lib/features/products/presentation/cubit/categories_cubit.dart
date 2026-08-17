import 'dart:async';

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
        emit(
          CategoriesLoaded(categories),
        );
      },
      onError: (error) {
        emit(
          CategoriesError(
            error.toString(),
          ),
        );
      },
    );
  }

  // ============================================================
  // Add Category
  // ============================================================

  Future<void> addCategory(String name) async {
    final trimmedName = name.trim();

    // ---------------- Validation ----------------

    if (trimmedName.isEmpty) {
      return;
    }

    // ---------------- Current Categories ----------------

    List<CategoryModel> currentCategories = [];

    if (state is CategoriesLoaded) {
      currentCategories =
          (state as CategoriesLoaded).categories;
    } else if (state is AddCategoryLoading) {
      currentCategories =
          (state as AddCategoryLoading).categories;
    } else if (state is AddCategoryError) {
      currentCategories =
          (state as AddCategoryError).categories;
    }

    // ---------------- Loading ----------------

    emit(
      AddCategoryLoading(
        currentCategories,
      ),
    );

    try {
      // ---------------- Firebase ----------------

      await repository.addCategory(trimmedName);

      // مهم:
      // لا نعمل emit للنجاح هنا.
      //
      // Firestore snapshots هتتحدث تلقائيًا
      // و watchCategories() هتعمل:
      //
      // CategoriesLoaded(updatedCategories)

    } catch (e) {
      emit(
        AddCategoryError(
          currentCategories,
          e.toString(),
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