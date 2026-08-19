import 'package:warshity/features/settings/data/datascource/settings_remote_data_source.dart';

class SettingsRepositery {
  final SettingsRemoteDataSource remoteDataSource;

  SettingsRepositery(this.remoteDataSource);

  Future<void> logOut() async {
    await remoteDataSource.logOut();
  }
}
