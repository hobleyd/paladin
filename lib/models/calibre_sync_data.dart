class CalibreSyncData {
  bool syncFromEpoch = false;
  int syncDate = 0;
  double progress = 0.0;
  String status = "";

  CalibreSyncData({this.syncFromEpoch = false, this.syncDate = 0, this.progress = 0.0, this.status = ""});

  CalibreSyncData copyWith({bool? syncFromEpoch, int? syncDate, double? progress, String? status}) {
    return CalibreSyncData(
      syncFromEpoch: syncFromEpoch ?? this.syncFromEpoch,
      syncDate: syncDate ?? this.syncDate,
      progress: progress ?? this.progress,
      status: status ?? this.status,
    );
  }
}