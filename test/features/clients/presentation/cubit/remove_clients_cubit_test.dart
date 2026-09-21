
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:warshity/features/clients/data/repo/clients_reprosatory.dart';
import 'package:warshity/features/clients/presentation/cubit/remove_clients_cubit.dart';
import 'package:warshity/features/clients/presentation/cubit/remove_clients_state.dart';

import 'clients_cubit_test.mocks.dart';

@GenerateMocks([ClientsRepository])
void main() {
  late MockClientsRepository repository;
  late RemoveClientCubit cubit;

  setUp(() {
    repository = MockClientsRepository();
    cubit = RemoveClientCubit(repository);
  });

  tearDown(() async {
    await cubit.close();
  });

  group('removeClient', () {
    test('Should emit loading then success when removeClient succeeds',
        () async {
      when(repository.removeClient('client-1'))
          .thenAnswer((_) async {});

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          const RemoveClientAction(
            status: RemoveClientStatus.loading,
          ),
          const RemoveClientAction(
            status: RemoveClientStatus.success,
          ),
        ]),
      );

      await cubit.removeClient(
        clientId: 'client-1',
      );

      await expectation;
    });

    test('Should emit loading then failure when removeClient fails',
        () async {
      when(repository.removeClient('client-1'))
          .thenThrow(Exception('Failed to remove client'));

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          const RemoveClientAction(
            status: RemoveClientStatus.loading,
          ),
          const RemoveClientAction(
            status: RemoveClientStatus.failure,
            errorMessage: 'Exception: Failed to remove client',
          ),
        ]),
      );

      await cubit.removeClient(
        clientId: 'client-1',
      );

      await expectation;
    });

    test('Should call repository with correct clientId', () async {
      when(repository.removeClient('client-1'))
          .thenAnswer((_) async {});

      await cubit.removeClient(
        clientId: 'client-1',
      );

      verify(repository.removeClient('client-1')).called(1);
    });
  });
}

