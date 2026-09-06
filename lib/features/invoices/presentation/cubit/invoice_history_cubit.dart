import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/features/invoices/data/repo/invoices_repository.dart';

import 'invoice_history_state.dart';

class InvoiceHistoryCubit extends Cubit<InvoiceHistoryState> {
  final InvoiceRepository repository;
  StreamSubscription? _subscription;

  InvoiceHistoryCubit(this.repository)
      : super(const InvoiceHistoryInitial()) {
    watchInvoices();
  }

  void watchInvoices() {
    emit(
      InvoiceHistoryLoading(
        invoices: state.invoices,
        search: state.search,
        filter: state.filter,
      ),
    );

    _subscription?.cancel();

    _subscription = repository.watchInvoices().listen(
      (invoices) {
        print('🔥 INVOICE HISTORY COUNT = ${invoices.length}');

        for (final invoice in invoices) {
          print(
            '📄 ${invoice.invoiceId} | '
            '${invoice.customerName} | '
            '${invoice.createdAt} | '
            '${invoice.total}',
          );
        }

        emit(
          InvoiceHistoryLoaded(
            invoices: invoices,
            search: state.search,
            filter: state.filter,
          ),
        );
      },
      onError: (error) {
        emit(
          InvoiceHistoryError(
            message: error.toString(),
            invoices: state.invoices,
            search: state.search,
            filter: state.filter,
          ),
        );
      },
    );
  }

  void searchInvoices(String value) {
    _emitLoaded(search: value);
  }

  void changeFilter(InvoiceFilter filter) {
    _emitLoaded(filter: filter);
  }

  Future<void> deleteInvoice(String invoiceId) async {
    try {
      await repository.deleteInvoice(invoiceId);
    } catch (e) {
      emit(
        InvoiceHistoryError(
          message: e.toString(),
          invoices: state.invoices,
          search: state.search,
          filter: state.filter,
        ),
      );
    }
  }

  void _emitLoaded({
    String? search,
    InvoiceFilter? filter,
  }) {
    emit(
      InvoiceHistoryLoaded(
        invoices: state.invoices,
        search: search ?? state.search,
        filter: filter ?? state.filter,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}