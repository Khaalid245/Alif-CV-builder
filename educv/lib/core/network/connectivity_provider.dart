import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Provides true if the device is offline, false if it has connectivity.
final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, bool>((ref) {
  return ConnectivityNotifier();
});

class ConnectivityNotifier extends StateNotifier<bool> {
  ConnectivityNotifier() : super(false) {
    _init();
  }

  Future<void> _init() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _updateStatus(connectivityResult);

    Connectivity().onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    // connectivity_plus 5.x.x returns a List of results
    final isOffline = results.every((r) => r == ConnectivityResult.none);
    if (state != isOffline) {
      state = isOffline;
    }
  }
}
