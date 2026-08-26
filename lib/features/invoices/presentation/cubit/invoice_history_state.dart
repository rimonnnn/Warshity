import 'package:warshity/features/invoices/data/models/invoice_model.dart';

enum InvoiceFilter {
  all,
  today,
  thisWeek,
  thisMonth,
  paid,
  unpaid,
}

abstract class InvoiceHistoryState {
  final List<InvoiceModel> invoices;
  final String search;
  final InvoiceFilter filter;

  const InvoiceHistoryState({
    this.invoices = const [],
    this.search = '',
    this.filter = InvoiceFilter.all,
  });
}

class InvoiceHistoryInitial extends InvoiceHistoryState {
  const InvoiceHistoryInitial();
}

class InvoiceHistoryLoading extends InvoiceHistoryState {
  const InvoiceHistoryLoading({
    super.invoices,
    super.search,
    super.filter,
  });
}

class InvoiceHistoryLoaded extends InvoiceHistoryState {
  const InvoiceHistoryLoaded({
    super.invoices,
    super.search,
    super.filter,
  });

  List<InvoiceModel> get filteredInvoices {
    final query = search.trim().toLowerCase();

    return invoices.where((invoice) {
      final matchesSearch =
          query.isEmpty ||
          (invoice.invoiceId ?? '').toLowerCase().contains(query) ||
          invoice.customerName.toLowerCase().contains(query);

      if (!matchesSearch) return false;

      final date = invoice.createdAt;
      final now = DateTime.now();

      switch (filter) {
        case InvoiceFilter.all:
          return true;

        case InvoiceFilter.today:
          return date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;

        case InvoiceFilter.thisWeek:
          final startOfWeek = DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(Duration(days: now.weekday - 1));

          return !date.isBefore(startOfWeek);

        case InvoiceFilter.thisMonth:
          return date.year == now.year &&
              date.month == now.month;

        case InvoiceFilter.paid:
          return invoice.remainingAmount <= 0;

        case InvoiceFilter.unpaid:
          return invoice.remainingAmount > 0;
      }
    }).toList();
  }

  int get totalInvoices => invoices.length;

  int get todayInvoices {
    final now = DateTime.now();

    return invoices.where((invoice) {
      final date = invoice.createdAt;

      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).length;
  }

  double get totalSales =>
      invoices.fold(0, (sum, invoice) => sum + invoice.total);

  int get unpaidInvoices =>
      invoices.where((invoice) => invoice.remainingAmount > 0).length;
}

class InvoiceHistoryError extends InvoiceHistoryState {
  final String message;

  const InvoiceHistoryError({
    required this.message,
    super.invoices,
    super.search,
    super.filter,
  });
}