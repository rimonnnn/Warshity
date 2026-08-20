import 'package:equatable/equatable.dart';

enum RemoveClientStatus { initial, loading, success, failure }

abstract class RemoveClientState extends Equatable {
  const RemoveClientState();

  @override
  List<Object?> get props => [];
}

class RemoveClientInitial extends RemoveClientState {
  const RemoveClientInitial();
}

class RemoveClientAction extends RemoveClientState {
  final RemoveClientStatus status;
  final String? errorMessage;

  const RemoveClientAction({
    this.status = RemoveClientStatus.initial,
    this.errorMessage,
  });

  RemoveClientAction copyWith({
    RemoveClientStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RemoveClientAction(
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
