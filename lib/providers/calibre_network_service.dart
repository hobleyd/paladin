import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'calibre_network_service.g.dart';

@Riverpod(keepAlive: true)
class CalibreNetworkService extends _$CalibreNetworkService {
  final String _calibreService = '_http._tcp';
  late BonsoirDiscovery _discovery;

  @override
  String build() {
    _discoverService();
    return "";
  }

  Future<void> _discoverService() async {
    // Once defined, we can start the discovery :
    _discovery = BonsoirDiscovery(type: _calibreService, printLogs: kReleaseMode);
    await _discovery.initialize();

    _discovery.eventStream!.listen((event) {
      switch (event) {
        case BonsoirDiscoveryServiceFoundEvent():
          event.service.resolve(_discovery.serviceResolver);
          break;
        case BonsoirDiscoveryServiceResolvedEvent():
          updateState(event.service);
          break;
        case BonsoirDiscoveryServiceUpdatedEvent():
          updateState(event.service);
          break;
        case BonsoirDiscoveryServiceLostEvent():
          state = "";
          break;
        default:
          break;
      }
    });

    // Start the discovery **after** listening to discovery events :
    await _discovery.start();
  }

  void updateState(BonsoirService service) {
    if (service.name == "calibre-service") {
      if (service.attributes != null) {
        String? host = service.attributes['server'];
        String? port = service.attributes['port'];
        if (host != null && port != null) {
          if (host.endsWith('.')) {
            host = host.substring(0, host.length - 1);
          }
          state = 'https://$host:$port';
        }
      }
    }
  }

  Future<void> cancelDiscovery() async {
    await _discovery.stop();
  }
}