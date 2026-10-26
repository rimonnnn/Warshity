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

  group('getActiveSharedAccounts while account sharing is disabled', () {
    test('returns an empty list without querying the repository', () async {
      final result = await accountSharingCubit.getActiveSharedAccounts();

      expect(result, isEmpty);
      expect(accountSharingCubit.connections, isEmpty);
      expect(accountSharingCubit.connectionsCount, 0);
      expect(accountSharingCubit.isShared, isFalse);
      expect(accountSharingCubit.sharedAccountId, isNull);
      verifyNever(mockRepository.getActiveSharedAccounts());
    });
  });
}
