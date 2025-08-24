import 'package:flutter/foundation.dart';

enum CalibreSyncState { NOTSTARTED, PROCESSING, REVIEW, COMPLETED }

@immutable
class CalibreSyncData {
  final String calibreServer;
  final bool syncFromEpoch;
  final bool syncReadStatuses;
  final double progress;
  final CalibreSyncState syncState;

  const CalibreSyncData({this.calibreServer = "", this.syncFromEpoch = false, this.syncReadStatuses = true, this.progress = 0.0, this.syncState = CalibreSyncState.NOTSTARTED,});

  String get stringState => switch (syncState) {
    CalibreSyncState.NOTSTARTED => "Not Started",
    CalibreSyncState.PROCESSING => "Processing",
    CalibreSyncState.REVIEW     => "Review",
    CalibreSyncState.COMPLETED  => "Completed",
  };

  CalibreSyncData copyWith({String? calibreServer, bool? syncFromEpoch, bool? syncReadStatuses, int? syncDate, double? progress, CalibreSyncState? syncState}) {
    return CalibreSyncData(
      calibreServer: calibreServer ?? this.calibreServer,
      syncFromEpoch: syncFromEpoch ?? this.syncFromEpoch,
      syncReadStatuses: syncReadStatuses ?? this.syncReadStatuses,
      progress: progress ?? this.progress,
      syncState: syncState ?? this.syncState,
    );
  }

  @override
  String toString() {
    return "$calibreServer ($stringState)";
  }
}