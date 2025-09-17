import 'package:android_package_installer/android_package_installer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/version_check.dart';
import '../../providers/update.dart';

class PaladinUpdate extends ConsumerWidget {
  const PaladinUpdate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    VersionCheck? versions = ref.watch(updateProvider).value;

    final String noUpdateLabel = 'There are no updates for Paladin as at this time.';
    return versions == null
        ? Padding(padding: EdgeInsetsGeometry.only(top: 30), child: Text(noUpdateLabel, style: Theme.of(context).textTheme.labelMedium))
        : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(padding: EdgeInsetsGeometry.only(top: 30), child: Text('Installed Version: ${versions.currentVersion}', style: Theme.of(context).textTheme.bodyMedium)),
            Text('Current Version: ${versions.newVersion}', style: Theme.of(context).textTheme.bodyMedium),
            if (versions.hasUpdate)
              Padding(padding: const EdgeInsets.only(top: 10), child: IconButton(icon: const Icon(Icons.download), onPressed: () => _download(ref, versions.downloadUrl, versions.downloadPackage))),
          ]
    );
  }

  // TODO: UX affordance for when we are downloading.
  Future<void> _download(WidgetRef ref, String url, String package) async {
    String apkPath = "${(await getTemporaryDirectory()).path}/$package}";
    await Dio().download(url, apkPath);
    int? statusCode = await AndroidPackageInstaller.installApk(apkFilePath: apkPath);
    if (statusCode != null) {
      PackageInstallerStatus installationStatus = PackageInstallerStatus.byCode(statusCode);
      debugPrint(installationStatus.name);
    }
  }
}