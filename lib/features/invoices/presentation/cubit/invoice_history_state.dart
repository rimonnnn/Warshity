import 'package:intl/intl.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';

enum InvoiceFilter { all, today, thisWeek, thisMonth, paid, unpaid }

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
  const InvoiceHistoryLoading({super.invoices, super.search, super.filter});
}

class InvoiceHistoryLoaded extends InvoiceHistoryState {
  const InvoiceHistoryLoaded({super.invoices, super.search, super.filter});

  // =========================
  // Date Parser
  // =========================

  DateTime? _parseInvoiceDate(String date) {
    try {
      return DateFormat('dd/MM/yyyy').parse(date);
    } catch (_) {
      return null;
    }
  }

  // =========================
  // Filtered Invoices
  // =========================

  List<InvoiceModel> get filteredInvoices {
    final query = search.trim().toLowerCase();
    final now = DateTime.now();

    return invoices.where((invoice) {
      // Search
      final matchesSearch =
          query.isEmpty ||
          (invoice.invoiceId ?? '').toLowerCase().contains(query) ||
          invoice.customerName.toLowerCase().contains(query);

      if (!matchesSearch) {
        return false;
      }

      // Convert String -> DateTime
      final date = _parseInvoiceDate(invoice.createdAt);

      // Invalid date
      if (date == null) {
        return false;
      }

      // Filter
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
          return date.year == now.year && date.month == now.month;

        case InvoiceFilter.paid:
          return invoice.remainingAmount <= 0;

        case InvoiceFilter.unpaid:
          return invoice.remainingAmount > 0;
      }
    }).toList();
  }

  // =========================
  // Statistics
  // =========================

  int get totalInvoices => invoices.length;

  int get todayInvoices {
    final now = DateTime.now();

    return invoices.where((invoice) {
      final date = _parseInvoiceDate(invoice.createdAt);

      if (date == null) {
        return false;
      }

      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).length;
  }

  double get totalSales {
    return invoices.fold(0.0, (sum, invoice) => sum + invoice.total);
  }

  int get unpaidInvoices {
    return invoices.where((invoice) => invoice.remainingAmount > 0).length;
  }
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
