import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'add_invoice_state.dart';

class AddInvoiceCubit extends Cubit<AddInvoiceState> {
  AddInvoiceCubit() : super(AddInvoiceInitial());
}
