import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as images;
import 'package:xml/xml.dart';

class Epub {
  final String bookName;
  final String bookPath;
  final String bookUUID;
  late Archive bookArchive;

  Epub({required this.bookName, required this.bookPath, required this.bookUUID});

  ArchiveFile? _findFileInArchive(String name, String opfPath) {
    ArchiveFile? archiveFile = bookArchive.find(name);
    archiveFile ??= bookArchive.find('${opfPath.split('/').firstOrNull}/$name');

    return archiveFile;
  }

  String? _getCoverImageFromHtml(String coverName, String opfPath) {
    ArchiveFile? xhtml = _findFileInArchive(coverName, opfPath);
    if (xhtml == null) {
      debugPrint("Can't find $coverName in epub!");
      return null;
    }

    XmlDocument xhtmlDocument = XmlDocument.parse(xhtml.getContent()!.readString());
    XmlElement? coverAttribute = xhtmlDocument.findAllElements('image').firstOrNull;

    if (coverAttribute != null) {
      return coverAttribute.getAttribute('xlink:href');
    }

    debugPrint("Can't find an image tag in the html");
    return null;
  }

  String? _getCoverImageFromXhtml(String coverName, String opfPath) {
    ArchiveFile? xhtml = _findFileInArchive(coverName, opfPath);
    if (xhtml == null) {
      debugPrint("Can't find $coverName in epub!");
      return null;
    }

    XmlDocument xhtmlDocument = XmlDocument.parse(xhtml.getContent()!.readString());
    XmlElement? coverAttribute = xhtmlDocument.findAllElements('section')
      .where((item) => item.getAttribute('epub:type')?.toLowerCase() == 'cover')
      .firstOrNull;

    if (coverAttribute != null) {
      XmlElement? coverImage = coverAttribute.findAllElements('img').firstOrNull;

      if (coverImage != null) {
        return coverImage.getAttribute('src');
      }
    }
    
    coverAttribute = xhtmlDocument.findAllElements('img')
      .where((item) => item.getAttribute('epub:type')?.toLowerCase() == 'cover')
      .firstOrNull;

    if (coverAttribute != null) {
      String? coverName = coverAttribute.getAttribute('src');
      if (coverName != null && coverName.startsWith('../')) {
        // TODO: really I should normalise pathnames in the Archive. When I decide it is worth doing, checkout
        // TODO: Run, Rose, Run (8fa575c4-1615-43ad-a7ad-e48317e32b94)
        coverName = coverName.substring(3);
      }
      return coverName;
    }

    debugPrint("Can't find an image tag in the xhtml");
    return null;
  }

  String? _getCoverName(XmlDocument opfContent) {
    XmlElement? coverAttribute = opfContent.findAllElements('item')
        .where((item) => item.getAttribute('id')?.toLowerCase() == 'cover'
        || item.getAttribute('id')?.toLowerCase() == 'cover-image'
        || item.getAttribute('id')?.toLowerCase() == 'my-cover-image'
        || item.getAttribute('id')?.toLowerCase() == 'cover-page'
        || item.getAttribute('properties')?.toLowerCase() == 'cover-image'
        || item.getAttribute('media-type')?.toLowerCase() == 'image/jpeg' // Relying on the fact that the first image should be the cover page. This might be luck. Review The Victorious Opposition (2902785a-7bdc-4d62-95a4-539b1be966fa) if this becomes a problem!
        || item.getAttribute('media-type')?.toLowerCase() == 'image/png') // Relying on the fact that the first image should be the cover page. This might be luck. Review Out of Phaze (82064c4a-e92a-4a4c-a1b4-fcf12f564273.epub) if this becomes a problem!
        .firstOrNull;

    if (coverAttribute == null) {
      debugPrint('$bookName ($bookUUID) does not have a cover attribute.');
      return null;
    }

    return coverAttribute.getAttribute('href');
  }

  XmlDocument? _getOPFContent(String opfPath) {
    InputStream? opf = bookArchive.find(opfPath)?.getContent();
    if (opf == null) {
      debugPrint("$bookName: OPF file is empty!!!");
      return null;
    }

    return XmlDocument.parse(opf.readString());
  }

  String? _getOPFPath() {
    InputStream? container = bookArchive.find('META-INF/container.xml')?.getContent();
    if (container == null) {
      debugPrint("$bookName ($bookUUID): Can't find container");
      return null;
    }

    final XmlDocument document = XmlDocument.parse(container.readString());
    XmlElement? rootfile = document.findAllElements('rootfile').firstOrNull;
    if (rootfile == null) {
      debugPrint("$bookName ($bookUUID): Can't find rootfile");
      return null;
    }

    return rootfile.getAttributeNode("full-path")?.value;
  }

  images.Image? getCover() {
    String? opfPath = _getOPFPath();
    if (opfPath == null) {
      debugPrint("$bookName ($bookUUID): Can't find opfPath");
      return null;
    }

    final XmlDocument? opfContent = _getOPFContent(opfPath);
    if (opfContent == null) {
      debugPrint("Couldn't parse OPF content");
      return null;
    }

    String? coverName = _getCoverName(opfContent);
    if (coverName != null) {
      if (coverName.endsWith('.xhtml')) {
        coverName = _getCoverImageFromXhtml(coverName, opfPath);
      } else if (coverName.endsWith('.html')) {
        coverName = _getCoverImageFromHtml(coverName, opfPath);
      }
    }

    if (coverName != null) {
      ArchiveFile? coverFile = _findFileInArchive(coverName, opfPath);

      Uint8List? coverBytes = coverFile?.readBytes();
      if (coverBytes == null) {
        debugPrint("$bookName: Cover image ($coverName) doesn't exist!");
        return null;
      }

      return images.decodeImage(coverBytes);
    }

    return null;
  }

  void openBook() {
    final inputStream = InputFileStream(bookPath);
    bookArchive = ZipDecoder().decodeStream(inputStream);
  }
}
