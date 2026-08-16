import 'dart:async';

import 'package:flutter/foundation.dart';

/// Turns a [Stream] into a [Listenable] for `go_router`.
///
/// `go_router` re-evaluates its redirect whenever its `refreshListenable`
/// fires, but Firebase reports auth changes as a stream. Without this adapter
/// a user who signs in would sit on the auth screen until they navigated by
/// hand, because nothing would prompt the redirect to run again.
class GoRouterRefreshStream extends ChangeNotifier {
  /// Listens to [stream] and notifies on every event.
  GoRouterRefreshStream(Stream<dynamic> stream) {
    // Fire once up front so the first redirect runs against current state
    // rather than waiting for the stream's first emission.
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (_) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
