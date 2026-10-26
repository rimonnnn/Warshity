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

  group('deleteSharedAccount while account sharing is disabled', () {
    test('emits a disabled error without deleting remotely', () async {
      final stateExpectation = expectLater(
        accountSharingCubit.stream,
        emits(isA<AccountSharingError>()),
      );

      await accountSharingCubit.deleteSharedAccount('connection-1');
      await stateExpectation;

      expect(accountSharingCubit.state, isA<AccountSharingError>());
      verifyNever(mockRepository.deleteSharedAccount(any));
      expect(accountSharingCubit.connections, isEmpty);
    });

    test('does not call the repository when connection id is empty', () async {
      await accountSharingCubit.deleteSharedAccount('');

      verifyNever(mockRepository.deleteSharedAccount(any));
      expect(accountSharingCubit.state, isA<AccountSharingInitial>());
    });
  });
}
