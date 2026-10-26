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

  group('hasReachedMaxConnections while account sharing is disabled', () {
    test('returns false because no shared connections are loaded', () async {
      await accountSharingCubit.getActiveSharedAccounts();

      expect(accountSharingCubit.hasReachedMaxConnections, isFalse);
      expect(accountSharingCubit.activeConnectionsCount, 0);
      verifyNever(mockRepository.getActiveSharedAccounts());
    });
  });
}
