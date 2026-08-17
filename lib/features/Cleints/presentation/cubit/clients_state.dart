part of 'clients_cubit.dart';

abstract class ClientsState extends Equatable {
  const ClientsState();

  @override
  List<Object?> get props => [];
}

enum ClientActionStatus { initial, loading, success, failure }

class ClientsInitial extends ClientsState {}

class ClientsLoading extends ClientsState {}

class ClientsLoaded extends ClientsState {
  final List<CustomerModel> clients;
  final List<CustomerModel> displayedClients;
  final String searchQuery;
  final ClientFilter filter;

  final ClientActionStatus actionStatus;
  final String? actionError;

  const ClientsLoaded({
    required this.clients,
    required this.displayedClients,
    this.searchQuery = '',
    this.filter = ClientFilter.all,
    this.actionStatus = ClientActionStatus.initial,
    this.actionError,
  });

  ClientsLoaded copyWith({
    List<CustomerModel>? clients,
    List<CustomerModel>? displayedClients,
    String? searchQuery,
    ClientFilter? filter,
    ClientActionStatus? actionStatus,
    String? actionError,
    bool clearActionError = false,
  }) {
    return ClientsLoaded(
      clients: clients ?? this.clients,
      displayedClients: displayedClients ?? this.displayedClients,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      actionStatus: actionStatus ?? this.actionStatus,
      actionError: clearActionError ? null : actionError ?? this.actionError,
    );
  }

  @override
  List<Object?> get props => [
    clients,
    displayedClients,
    searchQuery,
    filter,
    actionStatus,
    actionError,
  ];
}

class ClientsError extends ClientsState {
  final String message;

  const ClientsError(this.message);

  @override
  List<Object> get props => [message];
}
