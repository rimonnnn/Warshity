import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:warshity/core/errors/app_failure.dart';
import 'package:warshity/features/clients/presentation/cubit/clients_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/products_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/products_state.dart';

import '../../features/clients/presentation/cubit/clients_cubit_test.mocks.dart';
import '../../features/products/presentation/cubit/products_cubit_test.mocks.dart';

/// Regression tests for the white screen: a data source used to throw
/// synchronously (`user_not_authenticated`) while the widget tree was being
/// built. The watch calls must now be caught and surfaced as an error state
/// with a friendly, mapped message.
void main() {
  group('ProductsCubit', () {
    test('a synchronous throw becomes ProductsError, never a crash', () async {
      final repository = MockProductsRepository();

      when(
        repository.watchProducts(),
      ).thenThrow(const UnauthenticatedException());

      final cubit = ProductsCubit(repository);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([isA<ProductsLoading>(), isA<ProductsError>()]),
      );

      cubit.watchProducts();

      await expectation;

      final state = cubit.state as ProductsError;

      expect(state.message, isNotEmpty);
      expect(state.message, isNot(contains('UnauthenticatedException')));
      expect(state.message, isNot(contains('FirebaseException')));

      await cubit.close();
    });

    test('a permission-denied stream error is mapped, not raw', () async {
      final repository = MockProductsRepository();

      when(repository.watchProducts()).thenAnswer(
        (_) => Stream.error(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
            message: 'Missing or insufficient permissions.',
          ),
        ),
      );

      final cubit = ProductsCubit(repository);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([isA<ProductsLoading>(), isA<ProductsError>()]),
      );

      cubit.watchProducts();

      await expectation;

      final state = cubit.state as ProductsError;

      expect(state.message, isNot(contains('permission-denied')));
      expect(state.message, isNot(contains('Missing or insufficient')));

      await cubit.close();
    });
  });

  group('ClientsCubit', () {
    test('a synchronous throw becomes ClientsError, never a crash', () async {
      final repository = MockClientsRepository();

      when(
        repository.watchClients(),
      ).thenThrow(const UnauthenticatedException());

      final cubit = ClientsCubit(repository);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([isA<ClientsLoading>(), isA<ClientsError>()]),
      );

      cubit.watchClients();

      await expectation;

      final state = cubit.state as ClientsError;

      expect(state.message, isNotEmpty);
      expect(state.message, isNot(contains('UnauthenticatedException')));

      await cubit.close();
    });
  });
}
