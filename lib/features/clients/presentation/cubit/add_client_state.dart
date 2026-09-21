part of 'add_client_cubit.dart';

abstract class AddClientState extends Equatable {
  const AddClientState();

  @override
  List<Object> get props => [];
}

class AddClientInitial extends AddClientState {}

class AddClientLoading extends AddClientState {}

class AddClientSuccess extends AddClientState {}

class AddClientError extends AddClientState {
  final String message;
  const AddClientError(this.message);
  @override
  List<Object> get props => [message];
}
