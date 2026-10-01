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

  group('getSharedAccountId', () {
    test('should return existing shared account id', () async {
      when(
        mockRepository.getActiveSharedAccounts(),
      ).thenAnswer(
        (_) async => [
          {'id': 'connection-1'},
        ],
      );

      await accountSharingCubit.getActiveSharedAccounts();

      final result = await accountSharingCubit.getSharedAccountId();

      expect(result, 'connection-1');

      verify(mockRepository.getActiveSharedAccounts()).called(1);
    });

    test(
      'should call getActiveSharedAccounts when connections are empty',
      () async {
        when(
          mockRepository.getActiveSharedAccounts(),
        ).thenAnswer(
          (_) async => [
            {'id': 'connection-1'},
          ],
        );

        final result = await accountSharingCubit.getSharedAccountId();

        expect(result, 'connection-1');

        verify(mockRepository.getActiveSharedAccounts()).called(1);
      },
    );

    test('should return null when there is no shared account', () async {
      when(
        mockRepository.getActiveSharedAccounts(),
      ).thenAnswer((_) async => []);

      final result = await accountSharingCubit.getSharedAccountId();

      expect(result, isNull);

      verify(mockRepository.getActiveSharedAccounts()).called(1);
    });
  });
}
