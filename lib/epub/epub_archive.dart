import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:xml/xml.dart';

class Epub {
  void openBook(String bookPath) {
    final inputStream = InputFileStream(bookPath);
    final archive = ZipDecoder().decodeStream(inputStream);

    debugPrint('${basename(bookPath)}: ${archive.find("META-INF/container.xml")?.name}');
    InputStream? container = archive.find('META-INF/container.xml')?.getContent();
    if (container == null) {
      debugPrint('TODO: plan-b');
    }
    final XmlDocument document = XmlDocument.parse(container!.readString());
    for (var element in document.findElements('rootfiles')) {
      debugPrint('rootfile: ${element.attributes}');
    }
    debugPrint('Got document: $document\nfrom${container.readString()}');
  }
}
