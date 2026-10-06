part of '../layout/web_add_invoice.dart';

/// Invoice logic (dialogs, print, share, create) separated from the UI.
mixin _WebAddInvoiceActions on State<WebAddInvoice> {
  final GlobalKey _invoicePreviewKey = GlobalKey();

  late final InvoiceActionsService _actions = InvoiceActionsService(
    getIt<InvoicePdfService>(),
  );

  InvoiceModel? _readyInvoice;
  bool _invoiceSaved = false;

  InvoiceCubit get invoiceCubit;

  CategoriesCubit get categoriesCubit => context.read<CategoriesCubit>();

  bool get _canUseInvoiceActions => _readyInvoice != null;

  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? context.colors.error : null,
      ),
    );
  }

  void _showError(Object e) {
    if (!mounted) return;
    _showMessage(e.toString().replaceFirst('Exception: ', ''));
  }

  void _showAddClientDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => BlocProvider<AddClientCubit>(
        create: (_) => getIt<AddClientCubit>(),
        child: const AddClientDialog(),
      ),
    );
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: categoriesCubit),
          BlocProvider(create: (_) => getIt<AddProductCubit>()),
        ],
        child: const AddProductDialog(),
      ),
    );
  }

  Future<Uint8List> _generatePdf(InvoiceModel invoice) {
    return _actions.generatePdf(
      invoice: invoice,
      locale: context.locale,
      labels: context.invoiceLabels,
    );
  }

  Future<void> _finalizeInvoiceIfNeeded() async {
    final invoice = _readyInvoice;

    if (invoice == null || _invoiceSaved) return;

    await getIt<InvoicesRepository>().finalizeInvoice(invoice);

    if (!mounted) return;

    setState(() => _invoiceSaved = true);

    showAnimatedSnackDialog(
      context,
      message: 'invoice_created_successfully'.tr(),
      type: AnimatedSnackBarType.success,
    );
  }

  Future<void> _printInvoice() async {
    final invoice = _readyInvoice;
    if (invoice == null) return;

    try {
      final pdfBytes = await _generatePdf(invoice);
      final printed = await _actions.printPdf(pdfBytes);

      if (printed) await _finalizeInvoiceIfNeeded();
    } catch (e) {
      debugPrint('Print invoice error: $e');
      _showError(e);
    }
  }

  Future<void> _sharePdf() async {
    final invoice = _readyInvoice;
    if (invoice == null) return;

    try {
      final pdfBytes = await _generatePdf(invoice);

      await _actions.sharePdf(
        pdfBytes: pdfBytes,
        filename: '${invoice.invoiceId}.pdf',
      );
    } catch (e) {
      debugPrint('Share invoice error: $e');
      _showError(e);
    }
  }

  Future<void> _shareImage() async {
    final invoice = _readyInvoice;
    if (invoice == null) return;

    try {
      await _actions.exportImage(
        boundaryKey: _invoicePreviewKey,
        filename: '${invoice.invoiceId}.png',
      );
    } catch (e) {
      debugPrint('Share invoice image error: $e');
      _showError(e);
    }
  }

  void _openShareSheet() {
    if (!_canUseInvoiceActions) return;

    ShareOptionsSheet.show(
      context,
      onSharePdf: _sharePdf,
      onShareImage: _shareImage,
    );
  }

  void _createInvoice() {
    final state = invoiceCubit.state;

    if (state.selectedCustomerId == null ||
        state.selectedCustomerName == null) {
      _showMessage('please_select_customer'.tr(), error: true);
      return;
    }

    if (state.cartItems.isEmpty) {
      _showMessage('please_add_product'.tr(), error: true);
      return;
    }

    invoiceCubit.createInvoice();
  }

  void _onInvoiceStateChanged(BuildContext context, InvoiceState state) {
    if (state is InvoiceError) {
      setState(() {
        _readyInvoice = null;
        _invoiceSaved = false;
      });

      showAnimatedSnackDialog(
        context,
        message: state.message.replaceFirst('Exception: ', ''),
        type: AnimatedSnackBarType.error,
      );
    }

    if (state is InvoiceSuccess) {
      setState(() {
        _readyInvoice = state.invoice;
        _invoiceSaved = false;
      });

      showAnimatedSnackDialog(
        context,
        message: 'invoice_ready'.tr(),
        type: AnimatedSnackBarType.success,
      );
    }

    if (state is InvoiceLoaded && _readyInvoice != null) {
      setState(() {
        _readyInvoice = null;
        _invoiceSaved = false;
      });
    }
  }
}
