import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_service.g.dart';

/// Wraps `connectivity_plus` and exposes a clean [Stream<bool>] that emits
/// `true` when the device has an active network connection.
class ConnectivityService {
  ConnectivityService() {
    _connectivity = Connectivity();
    // Seed the stream with current state immediately
    _connectivity
        .checkConnectivity()
        .then((result) => _controller.add(_isConnected(result)));

    _connectivity.onConnectivityChanged.listen((result) {
      _controller.add(_isConnected(result));
    });
  }

  late final Connectivity _connectivity;
  final _controller = StreamController<bool>.broadcast();

  /// Emits `true` when at least one network interface is available.
  Stream<bool> get isConnected => _controller.stream;

  /// Synchronous check — use where a stream is not needed.
  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    return _isConnected(result);
  }

  void dispose() => _controller.close();

  bool _isConnected(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}

// ── Providers ─────────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
ConnectivityService connectivityService(Ref ref) {
  final svc = ConnectivityService();
  ref.onDispose(svc.dispose);
  return svc;
}

@Riverpod(keepAlive: true)
Stream<bool> connectivityStream(Ref ref) =>
    ref.watch(connectivityServiceProvider).isConnected;
