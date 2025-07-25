import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<String> getApplicationPath() async {
  String dir = "";
  if (!kIsWeb) {
    if (Platform.isAndroid || Platform.isMacOS) {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      dir = documentsDirectory.path;
    } else if (Platform.isWindows) {
      dir = path.join(Platform.environment['APPDATA']!, 'Paladin');
    } else {
      dir = path.join(Platform.environment['HOME']!, '.paladin');
    }
  }

  return dir;
}