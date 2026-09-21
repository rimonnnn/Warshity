import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:warshity/features/clients/data/repo/clients_reprosatory.dart';
import 'package:warshity/features/clients/presentation/cubit/debt_cubit.dart';

import 'clients_cubit_test.mocks.dart';

@GenerateMocks([ClientsRepository])
void main() {
  late MockClientsRepository repository;
  late DebtCubit cubit;

  setUp(() {
    repository = MockClientsRepository();
    cubit = DebtCubit(repository);
  });

  tearDown(() async {
    await cubit.close();
  });

  group('decreaseDebt', () {
    test(
      'Should emit loading then success when decreaseDebt succeeds',
      () async {
        when(
          repository.decreaseDebt(clientId: 'client-1', amount: 100),
        ).thenAnswer((_) async {});

        final expectation = expectLater(
          cubit.stream,
          emitsInOrder([
            const DebtAction(status: DebtActionStatus.loading),
            const DebtAction(status: DebtActionStatus.success),
          ]),
        );

        await cubit.decreaseDebt(clientId: 'client-1', amount: 100);

        await expectation;
      },
    );

    test('Should emit failure when decreaseDebt fails', () async {
      when(
        repository.decreaseDebt(clientId: 'client-1', amount: 100),
      ).thenThrow(Exception('Failed to decrease debt'));

      await cubit.decreaseDebt(clientId: 'client-1', amount: 100);

      expect(
        cubit.state,
        const DebtAction(
          status: DebtActionStatus.failure,
          errorMessage: 'Exception: Failed to decrease debt',
        ),
      );
    });

    test('Should call repository with correct clientId and amount', () async {
      when(
        repository.decreaseDebt(clientId: 'client-1', amount: 100),
      ).thenAnswer((_) async {});

      await cubit.decreaseDebt(clientId: 'client-1', amount: 100);

      verify(
        repository.decreaseDebt(clientId: 'client-1', amount: 100),
      ).called(1);
    });
  });
}
