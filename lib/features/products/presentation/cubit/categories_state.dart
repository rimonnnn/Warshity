import 'package:equatable/equatable.dart';

import 'package:warshity/features/products/data/models/category_model.dart';

abstract class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object?> get props => [];
}

class CategoriesInitial extends CategoriesState {}

class CategoriesLoading extends CategoriesState {}

class CategoriesLoaded extends CategoriesState {
  final List<CategoryModel> categories;

  const CategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class CategoriesError extends CategoriesState {
  final String message;

  const CategoriesError(this.message);

  @override
  List<Object?> get props => [message];
}

class AddCategoryLoading extends CategoriesState {
  final List<CategoryModel> categories;

  const AddCategoryLoading(this.categories);

  @override
  List<Object?> get props => [categories];
}

class AddCategoryError extends CategoriesState {
  final List<CategoryModel> categories;
  final String message;

  const AddCategoryError(
    this.categories,
    this.message,
  );

  @override
  List<Object?> get props => [
        categories,
        message,
      ];
}