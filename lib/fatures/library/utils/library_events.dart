// ============================================
// FILE: lib/fatures/library/utils/library_events.dart
// ============================================
//
// App-wide "My Library changed" signal. The library cubits listen and
// silently refresh, so the Library tab (kept alive in the bottom-nav
// IndexedStack) and any open library page update right away after a free
// item is added from a details screen.

import 'dart:async';

class LibraryEvents {
  LibraryEvents._();

  static final StreamController<void> _controller =
      StreamController<void>.broadcast();

  static Stream<void> get changes => _controller.stream;

  static void notifyChanged() => _controller.add(null);
}
