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

  group('getActiveConnectionIds while account sharing is disabled', () {
    test('returns no connection ids without querying the repository', () async {
      final result = await accountSharingCubit.getActiveConnectionIds();
      expect(result, isEmpty);
      verifyNever(mockRepository.getActiveConnectionIds());
    });
  });

  group('getConnectedUserIds', () {
    test('returns connected user ids from the repository', () async {
      final ids = ['user-1', 'user-2'];
      when(mockRepository.getConnectedUserIds()).thenAnswer((_) async => ids);

      final result = await accountSharingCubit.getConnectedUserIds();

      expect(result, ids);
      verify(mockRepository.getConnectedUserIds()).called(1);
    });
  });

  group('connectionIds while account sharing is disabled', () {
    test('remains empty without querying shared accounts', () async {
      await accountSharingCubit.getActiveSharedAccounts();
      expect(accountSharingCubit.connectionIds, isEmpty);
      verifyNever(mockRepository.getActiveSharedAccounts());
    });
  });
}
