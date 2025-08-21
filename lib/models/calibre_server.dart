import 'package:flutter/foundation.dart';

@immutable
class CalibreServer {
  final String calibreServer;
  final int lastConnected;

  const CalibreServer({required this.calibreServer, this.lastConnected = 0});

  static int get secondsSinceEpoch => (DateTime.now().millisecondsSinceEpoch / 1000).round();
  DateTime get lastConnectedDateTime => DateTime.fromMillisecondsSinceEpoch(lastConnected * 1000);

  CalibreServer copyWith({String? calibreServer, int? lastConnected}) {
    return CalibreServer(
      calibreServer: calibreServer ?? this.calibreServer,
      lastConnected: lastConnected ?? this.lastConnected,
    );
  }
}