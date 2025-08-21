import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as images;
import 'package:path/path.dart';
import 'package:xml/xml.dart';

class Epub {
  final String bookName;
  final String bookPath;
  late Archive bookArchive;

  Epub({required this.bookName, required this.bookPath});

  images.Image? getCover() {
    InputStream? container = bookArchive.find('META-INF/container.xml')?.getContent();
    if (container == null) {
      debugPrint("$bookName: Can't find container");
      return null;
    }

    final XmlDocument document = XmlDocument.parse(container!.readString());
    XmlElement rootfile = document.findAllElements('rootfile').first;
    if (rootfile == null) {
      debugPrint("$bookName: Can't find rootfile");
      return null;
    }

    String? opfPath = rootfile.getAttributeNode("full-path")?.value;
    if (opfPath == null) {
      debugPrint("$bookName: Can't find opfPath");
      return null;
    }

    InputStream? opf = bookArchive.find(opfPath!)?.getContent();
    if (opf == null) {
      debugPrint("$bookName: OPF file is empty!!!");
      return null;
    }

    final XmlDocument opfContent = XmlDocument.parse(opf!.readString());
    XmlElement coverAttribute = opfContent.findAllElements('item')
        .where((item) => item.getAttribute('id') == 'cover' || item.getAttribute('id') == 'cover-image')
        .first;

    Uint8List? coverBytes = bookArchive.find(coverAttribute.getAttribute('href')!)?.readBytes();
    if (coverBytes == null) {
      debugPrint("$bookName: Cover image (${coverAttribute.getAttribute('href')}) doesn't exist!");
      return null;
    }

    return images.decodeImage(coverBytes);
  }

  void openBook() {
    final inputStream = InputFileStream(bookPath);
    bookArchive = ZipDecoder().decodeStream(inputStream);
  }
}
