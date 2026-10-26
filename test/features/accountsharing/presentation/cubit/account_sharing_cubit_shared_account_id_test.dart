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

  group('getSharedAccountId while account sharing is disabled', () {
    test('returns null even when the repository has a shared account', () async {
      when(mockRepository.getActiveSharedAccounts()).thenAnswer(
        (_) async => [{'id': 'connection-1'}],
      );

      expect(await accountSharingCubit.getSharedAccountId(), isNull);
      verifyNever(mockRepository.getActiveSharedAccounts());
    });

    test('returns null when there is no shared account', () async {
      when(mockRepository.getActiveSharedAccounts()).thenAnswer((_) async => []);

      expect(await accountSharingCubit.getSharedAccountId(), isNull);
      verifyNever(mockRepository.getActiveSharedAccounts());
    });
  });
}
