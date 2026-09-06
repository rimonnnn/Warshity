import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:warshity/features/Cleints/data/repo/clients_reprosatory.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';
import 'package:warshity/features/invoices/data/repo/invoices_repository.dart';
import 'package:warshity/features/products/data/models/product_model.dart';
import 'package:warshity/features/products/data/repo/products_repository.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final ClientsRepository clientsRepository;
  final ProductsRepository productsRepository;
  final InvoiceRepository invoicesRepository;

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

  DateTime? _parseDate(String value) {
    return DateTime.tryParse(value) ?? DateFormat('dd/MM/yyyy').tryParse(value);
  }

  String formatInvoiceDate(String value) {
    final date = _parseDate(value);

    if (date == null) return value;

    if (DateTime.tryParse(value) != null) {
      return DateFormat('dd/MM/yyyy - hh:mm a').format(date);
    }

    return DateFormat('dd/MM/yyyy').format(date);
  }

  void _emitLoaded() {
    final now = DateTime.now();

    final todayInvoices = _invoices.where((invoice) {
      final date = _parseDate(invoice.createdAt);

      return date != null &&
          date.year == now.year &&
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
      ..sort((a, b) {
        final dateA = _parseDate(a.createdAt);
        final dateB = _parseDate(b.createdAt);

        if (dateA == null && dateB == null) {
          return 0;
        }

        if (dateA == null) {
          return 1;
        }

        if (dateB == null) {
          return -1;
        }

        return dateB.compareTo(dateA);
      });

    final lastFiveInvoices = recentInvoices.take(5).toList();

    emit(
      HomeLoaded(
        todaySales: todaySales,
        invoiceCount: _invoices.length,
        clientCount: _clientCount,
        productCount: _products.length,
        lowStockProducts: lowStockProducts,
        recentInvoices: lastFiveInvoices,
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
