import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/foundation.dart';
import 'package:paladin/providers/status_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'calibre_network_service.g.dart';

@Riverpod(keepAlive: true)
class CalibreNetworkService extends _$CalibreNetworkService {
  final String _calibreService = '_calibre-agent._tcp';
  late BonsoirDiscovery _discovery;

  @override
  String build() {
    _discoverService();
    return "";
  }

  Future<void> _discoverService() async {
    try {
      _discovery = BonsoirDiscovery(type: _calibreService, printLogs: kDebugMode);
      await _discovery.initialize();

      _discovery.eventStream!.listen(
        (event) {
          ref.read(statusProvider.notifier).addStatus('mDNS: event received: ${event.id}');
          switch (event) {
            case BonsoirDiscoveryStartedEvent():
              ref.read(statusProvider.notifier).addStatus('mDNS: discovery started for $_calibreService');
              break;
            case BonsoirDiscoveryServiceFoundEvent():
              ref.read(statusProvider.notifier).addStatus('mDNS: found "${event.service.name}" (${event.service.type}), resolving...');
              event.service.resolve(_discovery.serviceResolver);
              break;
            case BonsoirDiscoveryServiceResolvedEvent():
              ref.read(statusProvider.notifier).addStatus('mDNS: resolved "${event.service.name}" at ${event.service.hostAddresses} (port ${event.service.port})');
              updateState(event.service);
              break;
            case BonsoirDiscoveryServiceResolveFailedEvent():
              ref.read(statusProvider.notifier).addStatus('mDNS: resolve failed for a service');
              break;
            case BonsoirDiscoveryServiceUpdatedEvent():
              ref.read(statusProvider.notifier).addStatus('mDNS: updated "${event.service.name}"');
              updateState(event.service);
              break;
            case BonsoirDiscoveryServiceLostEvent():
              ref.read(statusProvider.notifier).addStatus('mDNS: lost "${event.service.name}"');
              break;
            case BonsoirDiscoveryStoppedEvent():
              ref.read(statusProvider.notifier).addStatus('mDNS: discovery stopped');
              break;
            default:
              ref.read(statusProvider.notifier).addStatus('mDNS: unknown event: ${event.id}');
              break;
          }
        },
        onError: (e) => ref.read(statusProvider.notifier).addStatus('mDNS stream error: $e'),
      );

      await _discovery.start();
      ref.read(statusProvider.notifier).addStatus('mDNS: scanning for $_calibreService services...');
    } catch (e) {
      ref.read(statusProvider.notifier).addStatus('mDNS discovery error: $e');
    }
  }

  void updateState(BonsoirService service) {
    if (!service.name.toLowerCase().startsWith('calibre-agent')) return;

    // Prioritise IPv4 addresses as the server is currently configured for anyIPv4
    String? host;
    for (var addr in service.hostAddresses) {
      if (!addr.contains(':')) {
        host = addr;
        break;
      }
    }
    host ??= service.hostAddress;

    int port = service.port;
    if (host != null) {
      if (host.endsWith('.')) {
        host = host.substring(0, host.length - 1);
      }
      String networkService = 'https://$host:$port';
      if (state != networkService) {
        ref.read(statusProvider.notifier).addStatus('Setting Calibre host to $networkService');
        state = networkService;
      }
    } else {
      ref.read(statusProvider.notifier).addStatus('mDNS: service resolved but no host address found');
    }
  }

  Future<void> cancelDiscovery() async {
    await _discovery.stop();
  }
}