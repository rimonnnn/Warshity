import 'dart:async';

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

    // startWatchingSharedAccounts subscribes to all three streams.
    // Give streams that are not relevant to a test safe defaults.
    when(
      mockRepository.watchActiveSharedAccounts(),
    ).thenAnswer((_) => const Stream.empty());
    when(
      mockRepository.watchSentInvitationStatuses(),
    ).thenAnswer((_) => const Stream.empty());
    when(
      mockRepository.watchReceivedInvitations(),
    ).thenAnswer((_) => const Stream.empty());

    accountSharingCubit = AccountSharingCubit(mockRepository);
  });

  tearDown(() async {
    await accountSharingCubit.close();
  });

  group('startWatchingSharedAccounts - remote changes', () {
    test(
      'should emit AccountInvitationAcceptedRemotely when a sent invitation '
      'changes from pending to accepted',
      () async {
        final statusesController = StreamController<Map<String, String>>();
        addTearDown(() => statusesController.close());

        when(
          mockRepository.watchSentInvitationStatuses(),
        ).thenAnswer((_) => statusesController.stream);

        final stateExpectation = expectLater(
          accountSharingCubit.stream,
          emitsThrough(isA<AccountInvitationAcceptedRemotely>()),
        );

        accountSharingCubit.startWatchingSharedAccounts();

        // The first snapshot establishes the baseline and should not emit an
        // "accepted remotely" event by itself.
        statusesController.add({'invitation-1': 'pending'});
        await Future<void>.delayed(Duration.zero);

        // The transition from pending to accepted is what the Cubit detects.
        statusesController.add({'invitation-1': 'accepted'});

        await stateExpectation;
      },
    );

    test(
      'should emit AccountSharedAccountDeletedRemotely when a connection '
      'disappears from the remote stream',
      () async {
        final controller =
            StreamController<List<Map<String, dynamic>>>();
        addTearDown(() => controller.close());

        when(
          mockRepository.watchActiveSharedAccounts(),
        ).thenAnswer((_) => controller.stream);

        accountSharingCubit.startWatchingSharedAccounts();

        // First snapshot initializes the current connection IDs.
        controller.add([
          {'id': 'connection-1'},
        ]);
        await Future<void>.delayed(Duration.zero);

        final stateExpectation = expectLater(
          accountSharingCubit.stream,
          emitsThrough(isA<AccountSharedAccountDeletedRemotely>()),
        );

        // The next snapshot removes the connection remotely.
        controller.add([]);

        await stateExpectation;
      },
    );
  });
}
