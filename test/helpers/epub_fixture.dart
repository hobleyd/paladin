import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as images;

final refProvider = Provider<Ref>((ref) => ref);

/// A [Ref] usable outside a widget tree, for classes (like `Epub`) that only
/// need it for status logging. The backing container is not autoDispose, so
/// no explicit keep-alive is needed.
Ref testRef() => ProviderContainer().read(refProvider);

/// Builds a zip archive at [path] from `archive path -> file bytes`.
void writeEpubFixture(String path, Map<String, List<int>> entries) {
  final archive = Archive();
  entries.forEach((name, bytes) => archive.add(ArchiveFile.bytes(name, bytes)));

  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(ZipEncoder().encodeBytes(archive));
}

/// A small solid-colour JPEG, usable as fixture cover image bytes.
Uint8List sampleCoverJpegBytes({int width = 4, int height = 4}) {
  final image = images.Image(width: width, height: height);
  images.fill(image, color: images.ColorRgb8(200, 100, 50));
  return images.encodeJpg(image);
}

const containerXml = '''
<?xml version="1.0"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:container">
  <rootfiles>
    <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
  </rootfiles>
</container>
''';
