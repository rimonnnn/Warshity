import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/features/Cleints/data/repo/clients_reprosatory.dart';
import 'package:warshity/features/add_invoices/data/repo/add_invoice_repository.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';
import 'package:warshity/features/products/data/models/product_model.dart';
import 'package:warshity/features/products/data/repo/products_repository.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final ClientsRepository clientsRepository;
  final ProductsRepository productsRepository;
  final InvoicesRepository invoicesRepository;

  StreamSubscription? _clientsSubscription;
  StreamSubscription? _productsSubscription;
  StreamSubscription? _invoicesSubscription;

  List<ProductModel> _products = [];
  List<InvoiceModel> _invoices = [];

  int _clientCount = 0;

  HomeCubit({
    required this.clientsRepository,
    required this.productsRepository,
    required this.invoicesRepository,
  }) : super(const HomeInitial()) {
    loadHome();
  }

  void loadHome() {
    emit(const HomeLoading());

    _clientsSubscription = clientsRepository.watchClients().listen((clients) {
      _clientCount = clients.length;
      _emitLoaded();
    }, onError: _handleError);

    _productsSubscription = productsRepository.watchProducts().listen((
      products,
    ) {
      _products = products;
      _emitLoaded();
    }, onError: _handleError);

    _invoicesSubscription = invoicesRepository.watchInvoices().listen((
      invoices,
    ) {
      _invoices = invoices;
      _emitLoaded();
    }, onError: _handleError);
  }

  void _emitLoaded() {
    final now = DateTime.now();

    final todayInvoices = _invoices.where((invoice) {
      final date = DateTime.tryParse(invoice.createdAt);

      if (date == null) {
        return false;
      }

      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).toList();

    final todaySales = todayInvoices.fold<double>(
      0,
      (sum, invoice) => sum + invoice.total,
    );

    final lowStockProducts = _products
        .where((product) => product.quantity <= 5)
        .toList();

    final recentInvoices = List<InvoiceModel>.from(_invoices)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    emit(
      HomeLoaded(
        todaySales: todaySales,
        invoiceCount: _invoices.length,
        clientCount: _clientCount,
        productCount: _products.length,
        lowStockProducts: lowStockProducts,
        recentInvoices: recentInvoices.take(5).toList(),
      ),
    );
  }

  void _handleError(Object error) {
    emit(HomeError(message: error.toString()));
  }

  @override
  Future<void> close() async {
    await _clientsSubscription?.cancel();
    await _productsSubscription?.cancel();
    await _invoicesSubscription?.cancel();

    return super.close();
  }
}
