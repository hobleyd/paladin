class CalibreSyncData {
  bool syncFromEpoch = false;
  bool syncReadStatuses = true;
  double progress = 0.0;
  String status = "";
  bool processing = false;

  CalibreSyncData({this.syncFromEpoch = false, this.syncReadStatuses = true, this.progress = 0.0, this.status = "", this.processing = false});

  CalibreSyncData copyWith({bool? syncFromEpoch, bool? syncReadStatuses, int? syncDate, double? progress, String? status, bool? processing}) {
    return CalibreSyncData(
      syncFromEpoch: syncFromEpoch ?? this.syncFromEpoch,
      syncReadStatuses: syncReadStatuses ?? this.syncReadStatuses,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      processing: processing ?? this.processing,
    );
  }
}