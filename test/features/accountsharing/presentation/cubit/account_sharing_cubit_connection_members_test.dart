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

  group('getConnectionMembers', () {
    test('should return connection members', () async {
      final members = ['user-1', 'user-2'];

      when(
        mockRepository.getConnectionMembers('connection-1'),
      ).thenAnswer((_) async => members);

      final result = await accountSharingCubit.getConnectionMembers(
        'connection-1',
      );

      expect(result, members);

      verify(
        mockRepository.getConnectionMembers('connection-1'),
      ).called(1);
    });
  });

  group('getConnectionMembers (repository call)', () {
    test('should call repository with correct connection id', () async {
      when(
        mockRepository.getConnectionMembers('connection-123'),
      ).thenAnswer((_) async => ['user-1', 'user-2']);

      await accountSharingCubit.getConnectionMembers('connection-123');

      verify(
        mockRepository.getConnectionMembers('connection-123'),
      ).called(1);
    });
  });
}
