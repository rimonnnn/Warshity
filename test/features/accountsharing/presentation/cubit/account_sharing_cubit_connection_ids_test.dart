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

  group('getActiveConnectionIds', () {
    test('should return active connection ids', () async {
      final ids = ['connection-1', 'connection-2'];

      when(
        mockRepository.getActiveConnectionIds(),
      ).thenAnswer((_) async => ids);

      final result = await accountSharingCubit.getActiveConnectionIds();

      expect(result, ids);

      verify(mockRepository.getActiveConnectionIds()).called(1);
    });
  });

  group('getConnectedUserIds', () {
    test('should return connected user ids', () async {
      final ids = ['user-1', 'user-2'];

      when(
        mockRepository.getConnectedUserIds(),
      ).thenAnswer((_) async => ids);

      final result = await accountSharingCubit.getConnectedUserIds();

      expect(result, ids);

      verify(mockRepository.getConnectedUserIds()).called(1);
    });
  });

  group('connectionIds', () {
    test('should return only valid connection ids', () async {
      when(
        mockRepository.getActiveSharedAccounts(),
      ).thenAnswer(
        (_) async => [
          {'id': 'connection-1'},
          {'id': ''},
          {},
          {'id': 'connection-2'},
        ],
      );

      await accountSharingCubit.getActiveSharedAccounts();

      expect(
        accountSharingCubit.connectionIds,
        ['connection-1', 'connection-2'],
      );
    });
  });
}
