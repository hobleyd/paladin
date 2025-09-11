import 'dart:convert';

import 'package:android_package_installer/android_package_installer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:version/version.dart';

void checkForUpdate() async {
  final response = await Dio().get('https://api.github.com/repos/hobleyd/paladin/releases/latest');
  if (response.statusCode == 200) {
    final Version githubVersion = Version.parse(response.data['tag_name']);
    final String url = response.data['assets'].first['browser_download_url'];

    final pubspec = await rootBundle.loadString("pubspec.yaml");
    Version buildVersion = Version.parse(pubspec.split("version: ")[1].split("\n")[0]);

    debugPrint('version: $githubVersion, from $buildVersion');
    if (githubVersion > buildVersion) {
      String apkPath = "${(await getTemporaryDirectory()).path}/${response.data['assets'].first['name']}";
      await Dio().download(url, apkPath);
      int? statusCode = await AndroidPackageInstaller.installApk(apkFilePath: apkPath);
      if (statusCode != null) {
        PackageInstallerStatus installationStatus = PackageInstallerStatus.byCode(statusCode);
        debugPrint(installationStatus.name);
      }
    }
  }
}