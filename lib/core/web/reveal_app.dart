import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:warshity/core/routing/router_generator_config.dart';
import 'package:warshity/core/web/preloader.dart';

/// يشيل الـ HTML preloader بعد ما الـ router يحدد أول route وتترسم frames فعلية.
Future<void> revealApp() async {
  final binding = WidgetsBinding.instance;
  final delegate = RouterGeneratorConfig.goRouter.routerDelegate;

  if (delegate.currentConfiguration.isEmpty) {
    final ready = Completer<void>();
    void onChange() {
      if (!delegate.currentConfiguration.isEmpty && !ready.isCompleted) {
        ready.complete();
      }
    }

    delegate.addListener(onChange);
    await ready.future;
    delegate.removeListener(onChange);
  }

  await binding.endOfFrame;
  await binding.endOfFrame;

  hideAppPreloader();
}