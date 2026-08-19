import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warshity/features/settings/data/repo/settings_repositery.dart';
import 'package:warshity/features/settings/presentation/cubit/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this.repository) : super(SettingsInitial());

  final SettingsRepositery repository;

 Future<void> logOut() async {
  emit(SettingsLoading());

  try {
    final stopwatch = Stopwatch()..start();

    await repository.logOut();

    stopwatch.stop();

    const minimumLoadingTime = Duration(milliseconds: 400);

    if (stopwatch.elapsed < minimumLoadingTime) {
      await Future.delayed(
        minimumLoadingTime - stopwatch.elapsed,
      );
    }

    emit(SettingsSuccess("logout_success".tr()));
  } catch (e) {
    emit(SettingsError(e.toString()));
  }
}
}