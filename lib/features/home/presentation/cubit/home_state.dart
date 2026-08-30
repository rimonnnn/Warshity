import 'package:warshity/features/invoices/data/models/invoice_model.dart';
import 'package:warshity/features/products/data/models/product_model.dart';

abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final double todaySales;
  final int invoiceCount;
  final int clientCount;
  final int productCount;
  final List<ProductModel> lowStockProducts;
  final List<InvoiceModel> recentInvoices;

  const HomeLoaded({
    required this.todaySales,
    required this.invoiceCount,
    required this.clientCount,
    required this.productCount,
    this.lowStockProducts = const [],
    this.recentInvoices = const [],
  });
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});
}