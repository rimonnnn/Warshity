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

  group('respondToInvitation - reject', () {
    test(
      'should emit [AccountSharingLoading, AccountInvitationRejected] when invitation is rejected',
      () async {
        when(
          mockRepository.respondToInvitation(
            invitationId: 'invitation-1',
            accept: false,
          ),
        ).thenAnswer((_) async {});

        final stateExpectation = expectLater(
          accountSharingCubit.stream,
          emitsInOrder([
            isA<AccountSharingLoading>(),
            isA<AccountInvitationRejected>(),
          ]),
        );

        await accountSharingCubit.respondToInvitation(
          invitationId: 'invitation-1',
          accept: false,
        );

        await stateExpectation;

        verify(
          mockRepository.respondToInvitation(
            invitationId: 'invitation-1',
            accept: false,
          ),
        ).called(1);
      },
    );

    test(
      'should emit [AccountSharingLoading, AccountSharingError] when rejecting invitation fails',
      () async {
        when(
          mockRepository.respondToInvitation(
            invitationId: 'invitation-1',
            accept: false,
          ),
        ).thenThrow(Exception('Reject failed'));

        final stateExpectation = expectLater(
          accountSharingCubit.stream,
          emitsInOrder([
            isA<AccountSharingLoading>(),
            isA<AccountSharingError>(),
          ]),
        );

        await accountSharingCubit.respondToInvitation(
          invitationId: 'invitation-1',
          accept: false,
        );

        await stateExpectation;

        verify(
          mockRepository.respondToInvitation(
            invitationId: 'invitation-1',
            accept: false,
          ),
        ).called(1);
      },
    );
  });
}
