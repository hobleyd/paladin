import 'package:flutter/foundation.dart';

@immutable
class CalibreSyncData {
  final String calibreServer;
  final bool syncFromEpoch;
  final bool syncReadStatuses;
  final double progress;
  final String status;
  final bool processing;

  CalibreSyncData({this.calibreServer = "", this.syncFromEpoch = false, this.syncReadStatuses = true, this.progress = 0.0, this.status = "", this.processing = false});

  CalibreSyncData copyWith({String? calibreServer, bool? syncFromEpoch, bool? syncReadStatuses, int? syncDate, double? progress, String? status, bool? processing}) {
    return CalibreSyncData(
      calibreServer: calibreServer ?? this.calibreServer,
      syncFromEpoch: syncFromEpoch ?? this.syncFromEpoch,
      syncReadStatuses: syncReadStatuses ?? this.syncReadStatuses,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      processing: processing ?? this.processing,
    );
  }

  @override
  String toString() {
    return "$calibreServer ($processing): $progress, $status";
  }
}