
import 'package:connectivity_plus/connectivity_plus.dart';

enum ConnectivityStatus { notDetermined, isConnected, isDisconnected }

class ConnectivityChecker {
  final Connectivity _connectivity = Connectivity();

  /// Checks internet connection only when called
  Future<ConnectivityStatus> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    return _mapConnectivityResult(results);
  }

  /// Maps the result to a custom ConnectivityStatus enum

  ConnectivityStatus _mapConnectivityResult(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.ethernet) ||
        results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi)) {
      return ConnectivityStatus.isConnected;
    }
    return ConnectivityStatus.isDisconnected;
  }
}