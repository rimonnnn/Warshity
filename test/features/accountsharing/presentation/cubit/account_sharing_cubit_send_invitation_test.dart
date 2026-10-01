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

  test('initial state should be AccountSharingInitial', () {
    expect(
      accountSharingCubit.state,
      isA<AccountSharingInitial>(),
    );
  });

  group('sendInvitation', () {
    test(
      'should emit [AccountSharingLoading, AccountInvitationSent] when succeeds',
      () async {
        when(
          mockRepository.sendInvitation(email: 'test@gmail.com'),
        ).thenAnswer((_) async {});

        final stateExpectation = expectLater(
          accountSharingCubit.stream,
          emitsInOrder([
            isA<AccountSharingLoading>(),
            isA<AccountInvitationSent>(),
          ]),
        );

        await accountSharingCubit.sendInvitation(email: 'test@gmail.com');

        await stateExpectation;

        verify(
          mockRepository.sendInvitation(email: 'test@gmail.com'),
        ).called(1);
      },
    );

    test(
      'should emit [AccountSharingLoading, AccountSharingError] when sending invitation fails',
      () async {
        when(
          mockRepository.sendInvitation(email: 'test@gmail.com'),
        ).thenThrow(Exception('Failed'));

        final stateExpectation = expectLater(
          accountSharingCubit.stream,
          emitsInOrder([
            isA<AccountSharingLoading>(),
            isA<AccountSharingError>(),
          ]),
        );

        await accountSharingCubit.sendInvitation(email: 'test@gmail.com');

        await stateExpectation;

        verify(
          mockRepository.sendInvitation(email: 'test@gmail.com'),
        ).called(1);
      },
    );
  });
}
