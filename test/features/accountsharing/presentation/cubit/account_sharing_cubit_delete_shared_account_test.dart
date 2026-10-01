import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:warshity/features/account_sharing/presentation/cubit/account_sharing_cubit.dart';
import 'package:warshity/features/account_sharing/presentation/cubit/account_sharing_state.dart';

import 'account_sharing_mocks.mocks.dart';
import 'account_sharing_test_helper.dart';

void main() {
  late MockAccountSharingRepository mockRepository;
  late AccountSharingCubit accountSharingCubit;

  setUp(() {
    mockRepository = createMockRepository();
    accountSharingCubit = AccountSharingCubit(mockRepository);
  });

  tearDown(() async {
    await accountSharingCubit.close();
  });

  group('deleteSharedAccount', () {
    test(
      'should emit [Loading, SharedAccountDeleted, StatusChanged] when succeeds',
      () async {
        when(
          mockRepository.getActiveSharedAccounts(),
        ).thenAnswer(
          (_) async => [
            {'id': 'connection-1'},
          ],
        );

        await accountSharingCubit.getActiveSharedAccounts();

        when(
          mockRepository.deleteSharedAccount('connection-1'),
        ).thenAnswer((_) async {});

        final stateExpectation = expectLater(
          accountSharingCubit.stream,
          emitsInOrder([
            isA<AccountSharingLoading>(),
            isA<AccountSharedAccountDeleted>(),
            isA<AccountSharingStatusChanged>(),
          ]),
        );

        await accountSharingCubit.deleteSharedAccount('connection-1');

        await stateExpectation;

        verify(mockRepository.deleteSharedAccount('connection-1')).called(1);

        expect(accountSharingCubit.connections, isEmpty);
      },
    );

    test('should not call repository when connection id is empty', () async {
      await accountSharingCubit.deleteSharedAccount('');

      verifyNever(mockRepository.deleteSharedAccount(any));

      expect(accountSharingCubit.state, isA<AccountSharingInitial>());
    });

    test(
      'should emit [AccountSharingLoading, AccountSharingError] when delete fails',
      () async {
        when(
          mockRepository.deleteSharedAccount('connection-1'),
        ).thenThrow(Exception('Delete failed'));

        final stateExpectation = expectLater(
          accountSharingCubit.stream,
          emitsInOrder([
            isA<AccountSharingLoading>(),
            isA<AccountSharingError>(),
          ]),
        );

        await accountSharingCubit.deleteSharedAccount('connection-1');

        await stateExpectation;

        verify(mockRepository.deleteSharedAccount('connection-1')).called(1);
      },
    );
  });
}
