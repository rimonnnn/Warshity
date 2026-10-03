import 'dart:js_interop';

@JS('hideAppPreloader')
external void _hideAppPreloader();

void hideAppPreloader() {
  try {
    _hideAppPreloader();
  } catch (_) {}
}