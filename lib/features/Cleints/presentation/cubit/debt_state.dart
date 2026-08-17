part of 'debt_cubit.dart';

enum DebtActionStatus { initial, loading, success, failure }

abstract class DebtState extends Equatable {
  const DebtState();

  @override
  List<Object?> get props => [];
}

class DebtInitial extends DebtState {
  const DebtInitial();
}

class DebtAction extends DebtState {
  final DebtActionStatus status;
  final String? errorMessage;

  const DebtAction({this.status = DebtActionStatus.initial, this.errorMessage});

  DebtAction copyWith({
    DebtActionStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DebtAction(
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
