import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/features/add_invoices/data/repo/add_invoice_repository.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/add_invoice_state.dart';

import 'package:warshity/features/invoices/data/models/invoice_item_model.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';

import 'package:warshity/features/products/data/models/product_model.dart';

class InvoiceCubit extends Cubit<InvoiceState> {
  InvoiceCubit(this.invoicesRepository) : super(const InvoiceInitial());

  final InvoicesRepository invoicesRepository;

  // =========================
  // Products
  // =========================

  void addProduct(ProductModel product) {
    final currentItems = List<InvoiceItemModel>.from(state.cartItems);

    final index = currentItems.indexWhere(
      (item) => item.productId == product.id,
    );

    if (index != -1) {
      final oldItem = currentItems[index];

      currentItems[index] = InvoiceItemModel(
        productId: oldItem.productId,
        productName: oldItem.productName,
        quantity: oldItem.quantity + 1,
        price: oldItem.price,
      );
    } else {
      currentItems.add(
        InvoiceItemModel(
          productId: product.id,
          productName: product.name,
          quantity: 1,
          price: product.price,
        ),
      );
    }

    _updateState(currentItems);
  }

  void removeProduct(String productId) {
    final currentItems = List<InvoiceItemModel>.from(state.cartItems);

    currentItems.removeWhere((item) => item.productId == productId);

    _updateState(currentItems);
  }

  void increaseQuantity(String productId) {
    final currentItems = List<InvoiceItemModel>.from(state.cartItems);

    final index = currentItems.indexWhere(
      (item) => item.productId == productId,
    );

    if (index == -1) return;

    final item = currentItems[index];

    currentItems[index] = InvoiceItemModel(
      productId: item.productId,
      productName: item.productName,
      quantity: item.quantity + 1,
      price: item.price,
    );

    _updateState(currentItems);
  }

  void decreaseQuantity(String productId) {
    final currentItems = List<InvoiceItemModel>.from(state.cartItems);

    final index = currentItems.indexWhere(
      (item) => item.productId == productId,
    );

    if (index == -1) return;

    final item = currentItems[index];

    if (item.quantity <= 1) {
      currentItems.removeAt(index);
    } else {
      currentItems[index] = InvoiceItemModel(
        productId: item.productId,
        productName: item.productName,
        quantity: item.quantity - 1,
        price: item.price,
      );
    }

    _updateState(currentItems);
  }

  // =========================
  // Discount
  // =========================

  void updateDiscount(double discount) {
    if (discount < 0) {
      discount = 0;
    }

    if (discount > 100) {
      discount = 100;
    }

    _emitWithTotals(cartItems: state.cartItems, discount: discount);
  }

  // =========================
  // Calculations
  // =========================

  double _calculateSubtotal(List<InvoiceItemModel> items) {
    return items.fold(0.0, (sum, item) {
      return sum + (item.price * item.quantity);
    });
  }

  void _updateState(List<InvoiceItemModel> items) {
    _emitWithTotals(cartItems: items, discount: state.discount);
  }

  void _emitWithTotals({
    required List<InvoiceItemModel> cartItems,
    required double discount,
  }) {
    final subtotal = _calculateSubtotal(cartItems);

    final discountAmount = subtotal * discount / 100;

    final total = subtotal - discountAmount;

    emit(
      InvoiceLoaded(
        selectedCustomerId: state.selectedCustomerId,
        selectedCustomerName: state.selectedCustomerName,
        cartItems: cartItems,
        discount: discount,
        subtotal: subtotal,
        total: total,
      ),
    );
  }

  // =========================
  // Customer
  // =========================

  void selectCustomer({
    required String customerId,
    required String customerName,
  }) {
    emit(
      InvoiceLoaded(
        selectedCustomerId: customerId,
        selectedCustomerName: customerName,
        cartItems: state.cartItems,
        discount: state.discount,
        subtotal: state.subtotal,
        total: state.total,
      ),
    );
  }

  void removeCustomer() {
    emit(
      InvoiceLoaded(
        selectedCustomerId: null,
        selectedCustomerName: null,
        cartItems: state.cartItems,
        discount: state.discount,
        subtotal: state.subtotal,
        total: state.total,
      ),
    );
  }

  // =========================
  // Create Invoice
  // =========================

  Future<void> createInvoice() async {
    if (state.selectedCustomerId == null ||
        state.selectedCustomerName == null) {
      emit(
        InvoiceError(
          message: 'Please select a customer',
          selectedCustomerId: state.selectedCustomerId,
          selectedCustomerName: state.selectedCustomerName,
          cartItems: state.cartItems,
          discount: state.discount,
          subtotal: state.subtotal,
          total: state.total,
        ),
      );

      return;
    }

    if (state.cartItems.isEmpty) {
      emit(
        InvoiceError(
          message: 'Please add at least one product',
          selectedCustomerId: state.selectedCustomerId,
          selectedCustomerName: state.selectedCustomerName,
          cartItems: state.cartItems,
          discount: state.discount,
          subtotal: state.subtotal,
          total: state.total,
        ),
      );

      return;
    }

    emit(
      InvoiceLoading(
        selectedCustomerId: state.selectedCustomerId,
        selectedCustomerName: state.selectedCustomerName,
        cartItems: state.cartItems,
        discount: state.discount,
        subtotal: state.subtotal,
        total: state.total,
      ),
    );

    try {
      final invoiceId = 'INV-${DateTime.now().millisecondsSinceEpoch}';

      final invoice = InvoiceModel(
        invoiceId: invoiceId,
        customerId: state.selectedCustomerId!,
        customerName: state.selectedCustomerName!,
        createdAt: DateTime.now(),
        items: state.cartItems,
        total: state.total,
        debt: state.total,
      );

      await invoicesRepository.createInvoice(invoice);

      emit(
        InvoiceSuccess(
          message: 'Invoice created successfully',
          selectedCustomerId: state.selectedCustomerId,
          selectedCustomerName: state.selectedCustomerName,
          cartItems: state.cartItems,
          discount: state.discount,
          subtotal: state.subtotal,
          total: state.total,
        ),
      );
    } catch (e) {
      emit(
        InvoiceError(
          message: e.toString(),
          selectedCustomerId: state.selectedCustomerId,
          selectedCustomerName: state.selectedCustomerName,
          cartItems: state.cartItems,
          discount: state.discount,
          subtotal: state.subtotal,
          total: state.total,
        ),
      );
    }
  }

  // =========================
  // Clear Cart
  // =========================

  void clearCart() {
    _emitWithTotals(cartItems: const [], discount: 0);
  }
}
