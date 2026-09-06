import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warshity/features/add_invoices/data/repo/add_invoice_repository.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/add_invoice_state.dart';
import 'package:warshity/features/check_invoice/data/invoice_pdf_data.dart';
import 'package:warshity/features/invoices/data/models/invoice_item_model.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';
import 'package:warshity/features/products/data/models/product_model.dart';

class InvoiceCubit extends Cubit<InvoiceState> {
  InvoiceCubit(this.invoicesRepository) : super(const InvoiceInitial());

  final InvoicesRepository invoicesRepository;

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

    currentItems.removeWhere(
      (item) => item.productId == productId,
    );

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

  void updateDiscount(double discount) {
    final subtotal = _calculateSubtotal(state.cartItems);

    final normalizedDiscount = discount.clamp(0, subtotal).toDouble();

    _emitWithTotals(
      cartItems: state.cartItems,
      discount: normalizedDiscount,
      paidAmount: state.paidAmount,
    );
  }

  void updatePaidAmount(double paidAmount) {
    _emitWithTotals(
      cartItems: state.cartItems,
      discount: state.discount,
      paidAmount: paidAmount,
    );
  }

  double _calculateSubtotal(List<InvoiceItemModel> items) {
    return items.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  void _updateState(List<InvoiceItemModel> items) {
    final subtotal = _calculateSubtotal(items);

    final discount = state.discount.clamp(0, subtotal).toDouble();

    _emitWithTotals(
      cartItems: items,
      discount: discount,
      paidAmount: state.paidAmount,
    );
  }

  void _emitWithTotals({
    required List<InvoiceItemModel> cartItems,
    required double discount,
    required double paidAmount,
  }) {
    final subtotal = _calculateSubtotal(cartItems);

    final normalizedDiscount = discount.clamp(0, subtotal).toDouble();

    final total = subtotal - normalizedDiscount;

    final newPaidAmount = paidAmount.clamp(0, total).toDouble();

    final remainingAmount = total - newPaidAmount;

    emit(
      InvoiceLoaded(
        invoiceId: state.invoiceId,
        selectedCustomerId: state.selectedCustomerId,
        selectedCustomerName: state.selectedCustomerName,
        createdAt: state.createdAt,
        cartItems: cartItems,
        discount: normalizedDiscount,
        subtotal: subtotal,
        total: total,
        paidAmount: newPaidAmount,
        remainingAmount: remainingAmount,
      ),
    );
  }

  void selectCustomer({
    required String customerId,
    required String customerName,
  }) {
    emit(
      InvoiceLoaded(
        invoiceId: state.invoiceId,
        selectedCustomerId: customerId,
        selectedCustomerName: customerName,
        createdAt: state.createdAt,
        cartItems: state.cartItems,
        discount: state.discount,
        subtotal: state.subtotal,
        total: state.total,
        paidAmount: state.paidAmount,
        remainingAmount: state.remainingAmount,
      ),
    );
  }

  void removeCustomer() {
    emit(
      InvoiceLoaded(
        invoiceId: state.invoiceId,
        selectedCustomerId: null,
        selectedCustomerName: null,
        createdAt: state.createdAt,
        cartItems: state.cartItems,
        discount: state.discount,
        subtotal: state.subtotal,
        total: state.total,
        paidAmount: state.paidAmount,
        remainingAmount: state.remainingAmount,
      ),
    );
  }

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
          createdAt: DateTime.now().toIso8601String(),
          paidAmount: state.paidAmount,
          remainingAmount: state.remainingAmount,
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
          paidAmount: state.paidAmount,
          remainingAmount: state.remainingAmount,
        ),
      );

      return;
    }

    final currentState = state;

    emit(
      InvoiceLoading(
        selectedCustomerId: currentState.selectedCustomerId,
        selectedCustomerName: currentState.selectedCustomerName,
        cartItems: currentState.cartItems,
        discount: currentState.discount,
        subtotal: currentState.subtotal,
        total: currentState.total,
        paidAmount: currentState.paidAmount,
        remainingAmount: currentState.remainingAmount,
      ),
    );

    try {
      final invoiceId =
          'INV-${DateTime.now().millisecondsSinceEpoch}';

      final createdAt = DateTime.now().toIso8601String();

      final invoice = InvoiceModel(
        invoiceId: invoiceId,
        customerId: currentState.selectedCustomerId!,
        customerName: currentState.selectedCustomerName!,
        createdAt: createdAt,
        items: currentState.cartItems,
        subtotal: currentState.subtotal,
        discount: currentState.discount,
        total: currentState.total,
        paidAmount: currentState.paidAmount,
        remainingAmount: currentState.remainingAmount,
      );

      await invoicesRepository.createInvoice(invoice);

      emit(
        InvoiceSuccess(
          message: 'Invoice created successfully',
          invoice: invoice,
          invoiceId: invoice.invoiceId,
          createdAt: invoice.createdAt,
          selectedCustomerId: currentState.selectedCustomerId,
          selectedCustomerName: currentState.selectedCustomerName,
          cartItems: currentState.cartItems,
          discount: currentState.discount,
          subtotal: currentState.subtotal,
          total: currentState.total,
          paidAmount: currentState.paidAmount,
          remainingAmount: currentState.remainingAmount,
        ),
      );
    } catch (e) {
      emit(
        InvoiceError(
          message: e.toString(),
          selectedCustomerId: currentState.selectedCustomerId,
          selectedCustomerName: currentState.selectedCustomerName,
          cartItems: currentState.cartItems,
          discount: currentState.discount,
          subtotal: currentState.subtotal,
          total: currentState.total,
          paidAmount: currentState.paidAmount,
          remainingAmount: currentState.remainingAmount,
        ),
      );
    }
  }

  InvoicePdfData getInvoicePdfData() {
    if (state.invoiceId == null ||
        state.createdAt == null ||
        state.selectedCustomerName == null) {
      throw Exception('Invoice data is incomplete');
    }

    return InvoicePdfData(
      invoiceId: state.invoiceId!,
      createdAt: state.createdAt!,
      customerName: state.selectedCustomerName!,
      items: List.unmodifiable(state.cartItems),
      subtotal: state.subtotal,
      discount: state.discount,
      total: state.total,
      paidAmount: state.paidAmount,
      remainingAmount: state.remainingAmount,
      discountAmount: state.discount,
    );
  }

  void clearCart() {
    _emitWithTotals(
      cartItems: const [],
      discount: 0,
      paidAmount: 0.0,
    );
  }
}