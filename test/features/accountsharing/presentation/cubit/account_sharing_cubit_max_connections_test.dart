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

  group('hasReachedMaxConnections', () {
    test('should return false when connections are less than 5', () async {
      when(
        mockRepository.getActiveSharedAccounts(),
      ).thenAnswer(
        (_) async => [
          {'id': '1'},
          {'id': '2'},
          {'id': '3'},
          {'id': '4'},
        ],
      );

      await accountSharingCubit.getActiveSharedAccounts();

      expect(accountSharingCubit.hasReachedMaxConnections, false);
    });

    test('should return true when connections reach 5', () async {
      when(
        mockRepository.getActiveSharedAccounts(),
      ).thenAnswer(
        (_) async => [
          {'id': '1'},
          {'id': '2'},
          {'id': '3'},
          {'id': '4'},
          {'id': '5'},
        ],
      );

      await accountSharingCubit.getActiveSharedAccounts();

      expect(accountSharingCubit.hasReachedMaxConnections, true);
    });
  });
}
