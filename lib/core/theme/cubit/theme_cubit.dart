import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/theme_service.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit(this._themeService) : super(const ThemeState.initial()) {
    _loadTheme();
  }

  final ThemeService _themeService;

  void _loadTheme() {
    final savedMode = _themeService.getThemeMode();
    emit(state.copyWith(themeMode: savedMode));
  }

  Future<void> toggleTheme() async {
    final newMode = state.isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await _themeService.saveThemeMode(newMode);
    emit(state.copyWith(themeMode: newMode));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _themeService.saveThemeMode(mode);
    emit(state.copyWith(themeMode: mode));
  }
}