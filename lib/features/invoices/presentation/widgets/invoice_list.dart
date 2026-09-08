import 'dart:typed_data';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:printing/printing.dart';

import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/extensions/invoice_pdf_labels.dart';
import 'package:warshity/core/utils/animated_snack_dialog.dart';

import 'package:warshity/features/check_invoice/data/invoice_actions_service.dart';
import 'package:warshity/features/check_invoice/data/invoice_pdf_data.dart';
import 'package:warshity/features/check_invoice/data/invoice_pdf_service.dart';
import 'package:warshity/features/check_invoice/presentation/widgets/check_invoice_content.dart';

import 'package:warshity/features/invoices/data/models/invoice_model.dart';
import 'package:warshity/features/invoices/data/repo/invoices_repository.dart';
import 'package:warshity/features/invoices/presentation/cubit/invoice_history_cubit.dart';
import 'package:warshity/features/invoices/presentation/cubit/invoice_history_state.dart';
import 'package:warshity/features/invoices/presentation/widgets/invoice_card.dart';

class InvoiceList extends StatelessWidget {
  const InvoiceList({super.key});

  String _formatDate(String value) {
    final date = DateTime.tryParse(value);

    if (date != null) {
      return DateFormat('dd/MM/yyyy hh:mm a').format(date);
    }

    final oldDate = DateFormat('dd/MM/yyyy').tryParse(value);

    if (oldDate != null) {
      return DateFormat('dd/MM/yyyy').format(oldDate);
    }

    return value;
  }

  Future<Uint8List> _generatePdf(
    BuildContext context,
    InvoiceModel invoice,
  ) async {
    final pdfService = getIt<InvoicePdfService>();

    final data = InvoicePdfData.fromInvoice(invoice);

    return pdfService.generateInvoicePdf(
      data,
      context.locale,
      context.invoiceLabels,
    );
  }

  Future<void> _printInvoice(
    BuildContext context,
    InvoiceModel invoice,
  ) async {
    try {
      final pdfBytes = await _generatePdf(context, invoice);

      await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes,
      );
    } catch (e) {
      if (!context.mounted) return;

      showAnimatedSnackDialog(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        type: AnimatedSnackBarType.error,
      );
    }
  }

  Future<void> _exportPdf(
    BuildContext context,
    InvoiceModel invoice,
  ) async {
    try {
      final pdfBytes = await _generatePdf(context, invoice);

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: '${invoice.invoiceId}.pdf',
      );
    } catch (e) {
      if (!context.mounted) return;

      showAnimatedSnackDialog(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        type: AnimatedSnackBarType.error,
      );
    }
  }

  Future<void> _exportImage(
    BuildContext context,
    InvoiceModel invoice,
  ) async {
    final invoiceKey = GlobalKey();

    try {
      final actions = InvoiceActionsService(
        getIt<InvoicePdfService>(),
      );

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            try {
              await WidgetsBinding.instance.endOfFrame;
              await WidgetsBinding.instance.endOfFrame;

              final imageBytes = await actions.captureAsImage(
                invoiceKey,
              );

              await actions.shareImage(
                imageBytes: imageBytes,
                filename: '${invoice.invoiceId}.png',
              );

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            } catch (e) {
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }

              if (context.mounted) {
                showAnimatedSnackDialog(
                  context,
                  message: e.toString().replaceFirst(
                    'Exception: ',
                    '',
                  ),
                  type: AnimatedSnackBarType.error,
                );
              }
            }
          });

          return Material(
            color: Colors.white,
            child: SingleChildScrollView(
              child: RepaintBoundary(
                key: invoiceKey,
                child: CheckInvoiceContent(
                  invoice: invoice,
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;

      showAnimatedSnackDialog(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        type: AnimatedSnackBarType.error,
      );
    }
  }

 Future<void> _deleteInvoice(
  BuildContext context,
  InvoiceModel invoice,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text('delete'.tr()),
        content: const Text(
          'Are you sure you want to delete this invoice?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: Text('delete'.tr()),
          ),
        ],
      );
    },
  );

  if (confirmed != true) return;

  // Loading أثناء الحذف
  showDialog(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (_) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    },
  );

  try {
    await getIt<InvoiceRepository>().deleteInvoice(
      invoice.invoiceId!,
    );

    if (!context.mounted) return;

    // نقفل Loading Dialog فقط
    Navigator.of(
      context,
      rootNavigator: true,
    ).pop();

    showAnimatedSnackDialog(
      context,
      message: 'Invoice deleted successfully',
      type: AnimatedSnackBarType.success,
    );
  } catch (e) {
    if (!context.mounted) return;

    // نقفل Loading Dialog في حالة الخطأ
    Navigator.of(
      context,
      rootNavigator: true,
    ).pop();

    showAnimatedSnackDialog(
      context,
      message: e.toString().replaceFirst(
        'Exception: ',
        '',
      ),
      type: AnimatedSnackBarType.error,
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoiceHistoryCubit, InvoiceHistoryState>(
      builder: (context, state) {
        // لو مفيش فواتير والـStream رجع Loading
        // نعرض الحالة الفارغة بدل Loading لا نهائي.
        if (state is InvoiceHistoryLoading &&
            state.invoices.isEmpty) {
          return const Center(
            child: Text('No invoices found'),
          );
        }

        if (state is InvoiceHistoryError &&
            state.invoices.isEmpty) {
          return Center(
            child: Text(state.message),
          );
        }

        if (state is! InvoiceHistoryLoaded) {
          return const SizedBox.shrink();
        }

        final invoices = state.filteredInvoices;

        if (invoices.isEmpty) {
          return const Center(
            child: Text('No invoices found'),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.only(bottom: 80.h),
          itemCount: invoices.length,
          itemBuilder: (context, index) {
            final invoice = invoices[index];

            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: InvoiceCard(
                invoiceNumber: invoice.invoiceId ?? '',
                customerName: invoice.customerName,
                date: _formatDate(invoice.createdAt),
                paymentMethod:
                    invoice.remainingAmount <= 0
                        ? 'paid'
                        : 'unpaid',
                itemCount: invoice.items.length,
                totalPrice:
                    '\$${invoice.total.toStringAsFixed(2)}',
                status:
                    invoice.remainingAmount <= 0
                        ? 'paid'
                        : 'unpaid',
                onPrint: () {
                  _printInvoice(context, invoice);
                },
                onExport: () {
                  _exportPdf(context, invoice);
                },
                onDelete: () {
                  _deleteInvoice(context, invoice);
                },
                onExportImage: () {
                  _exportImage(context, invoice);
                },
              ),
            );
          },
        );
      },
    );
  }
}