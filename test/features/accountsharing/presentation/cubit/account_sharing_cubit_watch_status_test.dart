import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:warshity/features/account_sharing/data/models/share_invitation_model.dart';
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

  group('watchReceivedInvitations', () {
    test('should return repository watchReceivedInvitations stream', () {
      final stream = Stream.value(<ShareInvitationModel>[]);

      when(
        mockRepository.watchReceivedInvitations(),
      ).thenAnswer((_) => stream);

      expect(
        accountSharingCubit.watchReceivedInvitations(),
        emits(isEmpty),
      );

      verify(mockRepository.watchReceivedInvitations()).called(1);
    });
  });

  group('startWatchingSharedAccounts - status', () {
    test(
      'should emit AccountSharingStatusChanged when shared accounts stream emits',
      () async {
        final controller = StreamController<List<Map<String, dynamic>>>();

        when(
          mockRepository.watchActiveSharedAccounts(),
        ).thenAnswer((_) => controller.stream);

        final stateExpectation = expectLater(
          accountSharingCubit.stream,
          emits(isA<AccountSharingStatusChanged>()),
        );

        accountSharingCubit.startWatchingSharedAccounts();

        controller.add([
          {'id': 'connection-1'},
        ]);

        await stateExpectation;

        expect(accountSharingCubit.sharedAccountId, 'connection-1');

        await controller.close();
      },
    );
  });
}
