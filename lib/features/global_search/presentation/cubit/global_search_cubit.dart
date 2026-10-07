
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/features/clients/data/model/customer_model.dart';
import 'package:warshity/features/clients/data/repo/clients_reprosatory.dart';
import 'package:warshity/features/global_search/data/model/global_search_result.dart';
import 'package:warshity/features/global_search/presentation/cubit/global_search_state.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';
import 'package:warshity/features/invoices/data/repo/invoices_repository.dart';
import 'package:warshity/features/products/data/models/product_model.dart';
import 'package:warshity/features/products/data/repo/products_repository.dart';

class GlobalSearchCubit extends Cubit<GlobalSearchState> {
  final ClientsRepository clientsRepository;
  final ProductsRepository productsRepository;
  final InvoiceRepository invoiceRepository;

  GlobalSearchCubit({
    required this.clientsRepository,
    required this.productsRepository,
    required this.invoiceRepository,
  }) : super(const GlobalSearchInitial());

  Future<void> search(String query) async {
    final value = query.trim().toLowerCase();

    if (value.isEmpty) {
      clear();
      return;
    }

    emit(const GlobalSearchLoading());

    try {
      final results = await Future.wait([
        clientsRepository.watchClients().first,
        productsRepository.watchProducts().first,
        invoiceRepository.watchInvoices().first,
      ]);

      final clients = results[0] as List<CustomerModel>;
      final products = results[1] as List<ProductModel>;
      final invoices = results[2] as List<InvoiceModel>;

      final clientResults = _searchClients(
        clients,
        value,
      );

      final productResults = _searchProducts(
        products,
        value,
      );

      final invoiceResults = _searchInvoices(
        invoices,
        value,
      );

      emit(
        GlobalSearchSuccess(
          clients: clientResults,
          products: productResults,
          invoices: invoiceResults,
        ),
      );
    } catch (e) {
      emit(
        GlobalSearchFailure(
          message: e.toString(),
        ),
      );
    }
  }

  List<GlobalSearchResult> _searchClients(
    List<CustomerModel> clients,
    String query,
  ) {
    return clients
        .where((client) {
          final name = client.name?.toLowerCase() ?? '';
          final phone = client.phone?.toLowerCase() ?? '';
          final address = client.address?.toLowerCase() ?? '';

          return name.contains(query) ||
              phone.contains(query) ||
              address.contains(query);
        })
        .map(
          (client) => GlobalSearchResult(
            type: GlobalSearchResultType.client,
            id: client.id ?? '',
            title: client.name ?? '',
            subtitle: client.phone,
          ),
        )
        .where((result) => result.id.isNotEmpty)
        .toList();
  }

  List<GlobalSearchResult> _searchProducts(
    List<ProductModel> products,
    String query,
  ) {
    return products
        .where((product) {
          final name = product.name.toLowerCase();
          final barcode = product.barcode.toLowerCase();
          final category = product.category.toLowerCase();

          return name.contains(query) ||
              barcode.contains(query) ||
              category.contains(query);
        })
        .map(
          (product) => GlobalSearchResult(
            type: GlobalSearchResultType.product,
            id: product.id,
            title: product.name,
            subtitle: product.barcode,
          ),
        )
        .toList();
  }

  List<GlobalSearchResult> _searchInvoices(
    List<InvoiceModel> invoices,
    String query,
  ) {
    return invoices
        .where((invoice) {
          final invoiceId = invoice.invoiceId?.toLowerCase() ?? '';
          final customerId = invoice.customerId.toLowerCase();
          final customerName = invoice.customerName.toLowerCase();
          final createdAt = invoice.createdAt.toLowerCase();

          final productNames = invoice.items
              .map((item) => item.productName.toLowerCase())
              .join(' ');

          return invoiceId.contains(query) ||
              customerId.contains(query) ||
              customerName.contains(query) ||
              createdAt.contains(query) ||
              productNames.contains(query);
        })
        .map(
          (invoice) => GlobalSearchResult(
            type: GlobalSearchResultType.invoice,
            id: invoice.invoiceId ?? invoice.customerId,
            title: invoice.customerName,
            subtitle: invoice.invoiceId,
          ),
        )
        .where((result) => result.id.isNotEmpty)
        .toList();
  }

  void clear() {
    emit(const GlobalSearchInitial());
  }
}

