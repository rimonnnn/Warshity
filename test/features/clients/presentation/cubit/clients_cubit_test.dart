import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:warshity/features/clients/data/model/customer_model.dart';
import 'package:warshity/features/clients/data/repo/clients_reprosatory.dart';
import 'package:warshity/features/clients/presentation/cubit/clients_cubit.dart';

import 'clients_cubit_test.mocks.dart';

@GenerateMocks([ClientsRepository])
void main() {
  late ClientsRepository repository;
  late ClientsCubit cubit;

  setUp(() {
    repository = MockClientsRepository();
    cubit = ClientsCubit(repository);
  });

  tearDown(() async {
    await cubit.close();
  });

  final clients = [
    CustomerModel(
      id: '1',
      name: 'Ahmed',
      phone: '01011111111',
      address: 'Beni Suef',
      balance: 500,
      hasDebt: true,
      invoices: [],
      totalPurchases: 1000,
      orderCount: 5,
    ),
    CustomerModel(
      id: '2',
      name: 'Mohamed',
      phone: '01122222222',
      address: 'Cairo',
      balance: 0,
      hasDebt: false,
      invoices: [],
      totalPurchases: 500,
      orderCount: 2,
    ),
    CustomerModel(
      id: '3',
      name: 'Ali',
      phone: '01233333333',
      address: 'Giza',
      balance: 200,
      hasDebt: true,
      invoices: [],
      totalPurchases: 700,
      orderCount: 3,
    ),
  ];

  group('watchClients', () {
    test('Should emit Loading then Loaded', () async {
      when(repository.watchClients()).thenAnswer((_) => Stream.value(clients));

      final states = <ClientsState>[];

      final subscription = cubit.stream.listen(states.add);

      cubit.watchClients();

      await Future.delayed(Duration.zero);

      expect(states[0], isA<ClientsLoading>());
      expect(states[1], isA<ClientsLoaded>());

      final loadedState = states[1] as ClientsLoaded;

      expect(loadedState.clients, clients);
      expect(loadedState.displayedClients, clients);

      await subscription.cancel();
    });

    test('Should emit Loading then Error', () async {
      when(
        repository.watchClients(),
      ).thenAnswer((_) => Stream.error(Exception('Failed to load clients')));

      final states = <ClientsState>[];

      final subscription = cubit.stream.listen(states.add);

      cubit.watchClients();

      await Future.delayed(Duration.zero);

      expect(states[0], isA<ClientsLoading>());
      expect(states[1], isA<ClientsError>());

      final errorState = states[1] as ClientsError;

      expect(errorState.message, 'Exception: Failed to load clients');

      await subscription.cancel();
    });
  });

  group('searchClients', () {
    setUp(() {
      when(repository.watchClients()).thenAnswer((_) => Stream.value(clients));

      cubit.watchClients();
    });

    test('Should search clients by name', () async {
      await Future.delayed(Duration.zero);

      cubit.searchClients('Ahmed');

      final state = cubit.state as ClientsLoaded;

      expect(state.displayedClients.length, 1);
      expect(state.displayedClients.first.name, 'Ahmed');
    });

    test('Should search clients by phone', () async {
      await Future.delayed(Duration.zero);

      cubit.searchClients('01122222222');

      final state = cubit.state as ClientsLoaded;

      expect(state.displayedClients.length, 1);
      expect(state.displayedClients.first.name, 'Mohamed');
    });

    test('Should search case-insensitively', () async {
      await Future.delayed(Duration.zero);

      cubit.searchClients('ahmed');

      final state = cubit.state as ClientsLoaded;

      expect(state.displayedClients.length, 1);
      expect(state.displayedClients.first.name, 'Ahmed');
    });

    test('Should trim search query', () async {
      await Future.delayed(Duration.zero);

      cubit.searchClients('  Ahmed  ');

      final state = cubit.state as ClientsLoaded;

      expect(state.displayedClients.length, 1);
      expect(state.displayedClients.first.name, 'Ahmed');
    });

    test('Should return all clients when search query is empty', () async {
      await Future.delayed(Duration.zero);

      cubit.searchClients('');

      final state = cubit.state as ClientsLoaded;

      expect(state.displayedClients.length, 3);
    });
  });

  group('filterClients', () {
    setUp(() {
      when(repository.watchClients()).thenAnswer((_) => Stream.value(clients));

      cubit.watchClients();
    });

    test('Should return all clients when filter is all', () async {
      await Future.delayed(Duration.zero);

      cubit.filterClients(ClientFilter.all);

      final state = cubit.state as ClientsLoaded;

      expect(state.displayedClients.length, 3);
    });

    test('Should return only clients with debt', () async {
      await Future.delayed(Duration.zero);

      cubit.filterClients(ClientFilter.hasDebt);

      final state = cubit.state as ClientsLoaded;

      expect(state.displayedClients.length, 2);

      expect(
        state.displayedClients.every((client) => client.balance! > 0),
        true,
      );
    });

    test('Should return only clients without debt', () async {
      await Future.delayed(Duration.zero);

      cubit.filterClients(ClientFilter.noDebt);

      final state = cubit.state as ClientsLoaded;

      expect(state.displayedClients.length, 1);
      expect(state.displayedClients.first.name, 'Mohamed');
    });
  });

  group('search + filter', () {
    setUp(() {
      when(repository.watchClients()).thenAnswer((_) => Stream.value(clients));

      cubit.watchClients();
    });

    test('Should apply search and filter together', () async {
      await Future.delayed(Duration.zero);

      cubit.searchClients('Ahmed');
      cubit.filterClients(ClientFilter.hasDebt);

      final state = cubit.state as ClientsLoaded;

      expect(state.displayedClients.length, 1);
      expect(state.displayedClients.first.name, 'Ahmed');
    });
  });

  test('Should do nothing when searching before clients are loaded', () {
    cubit.searchClients('Ahmed');

    expect(cubit.state, isA<ClientsInitial>());
  });
}
