import 'package:warshity/features/invoices/data/models/invoice_item_model.dart';

abstract class InvoiceState {
  final String? selectedCustomerId;
  final String? selectedCustomerName;

  final List<InvoiceItemModel> cartItems;

  final double discount;
  final double subtotal;
  final double total;

  const InvoiceState({
    this.selectedCustomerId,
    this.selectedCustomerName,
    this.cartItems = const [],
    this.discount = 0,
    this.subtotal = 0,
    this.total = 0,
  });
}

class InvoiceInitial extends InvoiceState {
  const InvoiceInitial();
}

class InvoiceLoading extends InvoiceState {
  const InvoiceLoading({
    super.selectedCustomerId,
    super.selectedCustomerName,
    super.cartItems,
    super.discount,
    super.subtotal,
    super.total,
  });
}

class InvoiceLoaded extends InvoiceState {
  const InvoiceLoaded({
    super.selectedCustomerId,
    super.selectedCustomerName,
    super.cartItems,
    super.discount,
    super.subtotal,
    super.total,
  });
}

class InvoiceSuccess extends InvoiceState {
  final String message;

  const InvoiceSuccess({
    required this.message,
    super.selectedCustomerId,
    super.selectedCustomerName,
    super.cartItems,
    super.discount,
    super.subtotal,
    super.total,
  });
}

class InvoiceError extends InvoiceState {
  final String message;

  const InvoiceError({
    required this.message,
    super.selectedCustomerId,
    super.selectedCustomerName,
    super.cartItems,
    super.discount,
    super.subtotal,
    super.total,
  });
}
