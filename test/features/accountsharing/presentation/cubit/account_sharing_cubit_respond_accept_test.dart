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

  group('respondToInvitation - accept while account sharing is disabled', () {
    test('emits a disabled error without calling the repository', () async {
      final stateExpectation = expectLater(
        accountSharingCubit.stream,
        emits(isA<AccountSharingError>()),
      );

      await accountSharingCubit.respondToInvitation(
        invitationId: 'invitation-1',
        accept: true,
      );
      await stateExpectation;

      expect(accountSharingCubit.state, isA<AccountSharingError>());
      expect(
        (accountSharingCubit.state as AccountSharingError).message,
        'Account sharing is temporarily disabled.',
      );
      verifyNever(mockRepository.respondToInvitation(
        invitationId: anyNamed('invitationId'),
        accept: anyNamed('accept'),
      ));
    });
  });
}
