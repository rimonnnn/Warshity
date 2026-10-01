import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:warshity/features/account_sharing/presentation/cubit/account_sharing_cubit.dart';

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

  group('getActiveSharedAccounts', () {
    test(
      'should return active shared accounts and update connections',
      () async {
        final accounts = [
          {'id': 'connection-1', 'email': 'test1@gmail.com'},
          {'id': 'connection-2', 'email': 'test2@gmail.com'},
        ];

        when(
          mockRepository.getActiveSharedAccounts(),
        ).thenAnswer((_) async => accounts);

        final result = await accountSharingCubit.getActiveSharedAccounts();

        expect(result, accounts);
        expect(accountSharingCubit.connections, accounts);
        expect(accountSharingCubit.connectionsCount, 2);
        expect(accountSharingCubit.isShared, true);
        expect(accountSharingCubit.sharedAccountId, 'connection-1');

        verify(mockRepository.getActiveSharedAccounts()).called(1);
      },
    );

    test(
      'should return empty list when there are no active shared accounts',
      () async {
        when(
          mockRepository.getActiveSharedAccounts(),
        ).thenAnswer((_) async => []);

        final result = await accountSharingCubit.getActiveSharedAccounts();

        expect(result, isEmpty);
        expect(accountSharingCubit.connections, isEmpty);
        expect(accountSharingCubit.isShared, false);
        expect(accountSharingCubit.sharedAccountId, isNull);

        verify(mockRepository.getActiveSharedAccounts()).called(1);
      },
    );
  });
}
