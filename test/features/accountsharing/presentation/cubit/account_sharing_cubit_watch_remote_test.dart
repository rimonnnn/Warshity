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
    accountSharingCubit = AccountSharingCubit(mockRepository);
  });

  tearDown(() async {
    await accountSharingCubit.close();
  });

  group('startWatchingSharedAccounts - remote changes', () {
    test(
      'should emit AccountInvitationAcceptedRemotely when new connection is added',
      () async {
        final controller = StreamController<List<Map<String, dynamic>>>();

        when(
          mockRepository.watchActiveSharedAccounts(),
        ).thenAnswer((_) => controller.stream);

        accountSharingCubit.startWatchingSharedAccounts();

        controller.add([]);

        await Future<void>.delayed(Duration.zero);

        final stateExpectation = expectLater(
          accountSharingCubit.stream,
          emits(isA<AccountInvitationAcceptedRemotely>()),
        );

        controller.add([
          {'id': 'connection-1'},
        ]);

        await stateExpectation;

        await controller.close();
      },
    );

    test(
      'should emit AccountSharedAccountDeletedRemotely when connection is removed',
      () async {
        final controller = StreamController<List<Map<String, dynamic>>>();

        when(
          mockRepository.watchActiveSharedAccounts(),
        ).thenAnswer((_) => controller.stream);

        accountSharingCubit.startWatchingSharedAccounts();

        controller.add([
          {'id': 'connection-1'},
        ]);

        await Future<void>.delayed(Duration.zero);

        final stateExpectation = expectLater(
          accountSharingCubit.stream,
          emits(isA<AccountSharedAccountDeletedRemotely>()),
        );

        controller.add([]);

        await stateExpectation;

        await controller.close();
      },
    );
  });
}
