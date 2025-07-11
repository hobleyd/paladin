class CalibreSyncData {
  bool syncFromEpoch = false;
  double progress = 0.0;
  String status = "";
  bool processing = false;

  CalibreSyncData({this.syncFromEpoch = false, this.progress = 0.0, this.status = "", this.processing = false});

  CalibreSyncData copyWith({bool? syncFromEpoch, int? syncDate, double? progress, String? status, bool? processing}) {
    return CalibreSyncData(
      syncFromEpoch: syncFromEpoch ?? this.syncFromEpoch,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      processing: processing ?? this.processing,
    );
  }
}