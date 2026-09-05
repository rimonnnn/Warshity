import 'package:warshity/features/invoices/data/models/invoice_item_model.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';

abstract class InvoiceState {
  final String? invoiceId;

  final String? selectedCustomerId;
  final String? selectedCustomerName;

  final String? createdAt;

  final List<InvoiceItemModel> cartItems;

  final double discount;
  final double subtotal;
  final double total;

  final double paidAmount;
  final double remainingAmount;

  const InvoiceState({
    this.invoiceId,
    this.selectedCustomerId,
    this.selectedCustomerName,
    this.createdAt,
    this.cartItems = const [],
    this.discount = 0,
    this.subtotal = 0,
    this.total = 0,
    this.paidAmount = 0,
    this.remainingAmount = 0,
  });
}

class InvoiceInitial extends InvoiceState {
  const InvoiceInitial();
}

class InvoiceLoading extends InvoiceState {
  const InvoiceLoading({
    super.invoiceId,
    super.selectedCustomerId,
    super.selectedCustomerName,
    super.createdAt,
    super.cartItems,
    super.discount,
    super.subtotal,
    super.total,
    super.paidAmount,
    super.remainingAmount,
  });
}

class InvoiceLoaded extends InvoiceState {
  const InvoiceLoaded({
    super.invoiceId,
    super.selectedCustomerId,
    super.selectedCustomerName,
    super.createdAt,
    super.cartItems,
    super.discount,
    super.subtotal,
    super.total,
    super.paidAmount,
    super.remainingAmount,
  });
}

class InvoiceSuccess extends InvoiceState {
  final String message;
  final InvoiceModel invoice;

  const InvoiceSuccess({
    required this.message,
    required this.invoice,
    super.invoiceId,
    super.selectedCustomerId,
    super.selectedCustomerName,
    super.createdAt,
    super.cartItems,
    super.discount,
    super.subtotal,
    super.total,
    super.paidAmount,
    super.remainingAmount,
  });
}

class InvoiceError extends InvoiceState {
  final String message;

  const InvoiceError({
    required this.message,
    super.invoiceId,
    super.selectedCustomerId,
    super.selectedCustomerName,
    super.createdAt,
    super.cartItems,
    super.discount,
    super.subtotal,
    super.total,
    super.paidAmount,
    super.remainingAmount,
  });
}