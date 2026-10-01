import 'package:mockito/mockito.dart';

import 'account_sharing_mocks.mocks.dart';

/// Creates a mock repository with the default stubs
/// required by the AccountSharingCubit constructor.
MockAccountSharingRepository createMockRepository() {
  final repository = MockAccountSharingRepository();

  when(
    repository.watchActiveSharedAccounts(),
  ).thenAnswer(
    (_) => const Stream.empty(),
  );

  when(
    repository.watchSentInvitationStatuses(),
  ).thenAnswer(
    (_) => const Stream.empty(),
  );

  return repository;
}
