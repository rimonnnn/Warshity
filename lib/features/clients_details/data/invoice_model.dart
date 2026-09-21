class InvoiceClientsModel {
  final String invoiceNumber;
  final String customerName;
  final String date;
  final String paymentMethod;
  final int itemCount;
  final String totalPrice;

  const InvoiceClientsModel({
    required this.invoiceNumber,
    required this.customerName,
    required this.date,
    required this.paymentMethod,
    required this.itemCount,
    required this.totalPrice,
  });
}