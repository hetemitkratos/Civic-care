import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  late StreamController<bool> _connectionController;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _isOnline = true;

  ConnectivityService() {
    _connectionController = StreamController<bool>.broadcast();
    _initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Stream<bool> get connectionStream => _connectionController.stream;
  bool get isOnline => _isOnline;

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      _isOnline = false;
      _connectionController.add(false);
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final wasOnline = _isOnline;
    _isOnline = result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet;

    if (wasOnline != _isOnline) {
      _connectionController.add(_isOnline);
    }
  }

  void dispose() {
    _connectivitySubscription.cancel();
    _connectionController.close();
  }
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
});

final connectivityProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectionStream;
});
