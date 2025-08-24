import 'package:archive/archive.dart';
import 'package:dartlin/collections.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as images;
import 'package:xml/xml.dart';

class Epub {
  final String bookName;
  final String bookPath;
  final String bookUUID;
  late Archive bookArchive;

  Epub({required this.bookName, required this.bookPath, required this.bookUUID}) {
    openBook();
  }

  // Some (older, admittedly) epub archives don't have reliably consistent filenames in the archive; so look for the value
  // ending in what we are looking for and this should catch everything I've seen; so far, at least.
  ArchiveFile? _findFileInArchive(String name) {
    try {
      return bookArchive.files.firstWhere((file) => file.name.endsWith(Uri.decodeFull(name)));
    } catch (e) {
      return null;
    }
  }

  String? _getCoverImageFromHtml(String coverName) {
    ArchiveFile? xhtml = _findFileInArchive(coverName);
    if (xhtml == null) {
      debugPrint("Can't find $coverName in epub!");
      return null;
    }

    XmlDocument xhtmlDocument = XmlDocument.parse(xhtml.getContent()!.readString());
    XmlElement? coverAttribute = xhtmlDocument.findAllElements('image').firstOrNull();

    if (coverAttribute != null) {
      return coverAttribute.getAttribute('xlink:href');
    }

    // Option 2: <figure data-type="cover" id="bookcover01"><img src="cover.jpg"/></figure>
    coverAttribute = xhtmlDocument.findAllElements('figure')
        .where((item) => item.getAttribute('data-type')?.toLowerCase() == 'cover')
        .firstOrNull();
    if (coverAttribute != null) {
      coverAttribute = coverAttribute.findAllElements('img').firstOrNull();
      if (coverAttribute != null) {
        return coverAttribute.getAttribute('src');
      }
    }

    coverAttribute = xhtmlDocument.findAllElements('img').firstOrNull();
    if (coverAttribute != null) {
      return coverAttribute.getAttribute('src');
    }

    debugPrint("Can't find an image tag in the html");
    return null;
  }

  String? _getCoverImageFromXhtml(String coverName) {
    ArchiveFile? xhtml = _findFileInArchive(coverName);
    if (xhtml == null) {
      debugPrint("Can't find $coverName in epub!");
      return null;
    }

    // Option 1: <section><img/></section>
    XmlDocument xhtmlDocument = XmlDocument.parse(xhtml.getContent()!.readString());
    XmlElement? coverAttribute = xhtmlDocument.findAllElements('section')
      .where((item) => item.getAttribute('epub:type')?.toLowerCase() == 'cover')
      .firstOrNull();

    if (coverAttribute != null) {
      XmlElement? coverImage = coverAttribute.findAllElements('img').firstOrNull();

      if (coverImage != null) {
        return coverImage.getAttribute('src');
      }
    }

    // Option 2: <img epub-type="cover"/>
    coverAttribute = xhtmlDocument.findAllElements('img')
      .where((item) => item.getAttribute('epub:type')?.toLowerCase() == 'cover'
          || item.getAttribute('id')?.toLowerCase() == 'cover'
          || item.getAttribute('alt')?.toLowerCase() == 'cover')
      .firstOrNull();

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
    List<XmlElement> coverElements = opfContent.findAllElements('item')
        .where((item) => item.getAttribute('id')?.toLowerCase() == 'cover-image'
        || item.getAttribute('id')?.toLowerCase() == 'my-cover-image'
        || item.getAttribute('id')?.toLowerCase() == 'cover'
        || item.getAttribute('id')?.toLowerCase() == 'cov'
        || item.getAttribute('id')?.toLowerCase() == 'cover-jpg'
        || item.getAttribute('id')?.toLowerCase() == 'cover.jpg'
        || item.getAttribute('id')?.toLowerCase() == 'cover.jpeg'
        || item.getAttribute('id')?.toLowerCase() == 'img_cover'
        || item.getAttribute('id')?.toLowerCase() == 'coverimagestandard'
        || item.getAttribute('id')?.toLowerCase() == 'cover-page'
        || item.getAttribute('properties')?.toLowerCase() == 'cover-image').toList();
        //|| item.getAttribute('media-type')?.toLowerCase() == 'image/jpeg' // Relying on the fact that the first image should be the cover page. This might be luck. Review The Victorious Opposition (2902785a-7bdc-4d62-95a4-539b1be966fa) if this becomes a problem!
        //|| item.getAttribute('media-type')?.toLowerCase() == 'image/png').toList(); // Relying on the fact that the first image should be the cover page. This might be luck. Review Out of Phaze (82064c4a-e92a-4a4c-a1b4-fcf12f564273.epub) if this becomes a problem!

    if (coverElements.length == 1) {
      return coverElements.first.getAttribute('href');
    } else if (coverElements.length > 1) {
      // TODO: Assume if there are multiples, there will always be an image.
      return coverElements.firstWhere((element) {
        return element.getAttribute('href')!.endsWith('jpg') || element.getAttribute('href')!.endsWith('png');
      }).getAttribute('href');
    } else {
      // Try the hard way - get the first page in the Spine and assume that contains the cover.
      XmlElement spine = opfContent.findAllElements('spine').first;
      XmlElement firstPage = spine.findAllElements('itemref').first;
      String pageRef = firstPage.getAttribute('idref')!;

      XmlElement? page = opfContent.findAllElements('item')
          .where((item) => item.getAttribute('id')!.toLowerCase() == pageRef.toLowerCase())
          .firstOrNull();

      if (page != null) {
        return page.getAttribute('href');
      }

      debugPrint('$bookName ($bookUUID) does not have a cover attribute.');
      return null;
    }
  }

  XmlDocument? _getOPFContent(String opfPath) {
    InputStream? opf = _findFileInArchive(opfPath)?.getContent();
    if (opf == null) {
      debugPrint("$bookName: OPF file is empty!!!");
      return null;
    }

    return XmlDocument.parse(opf.readString());
  }

  String? _getOPFPath() {
    // We need to check twice, because while most epubs have a single container.xml in the root of the Archive,
    // some have it in a sub folder and so _findFileInArchive is required. We can't just search for it that way though
    // because other archives have multiple containers and we need to preference the top level one.
    ArchiveFile? container = bookArchive.find('META-INF/container.xml');
    container ??= _findFileInArchive('META-INF/container.xml');

    InputStream? containerStream = container?.getContent();
    if (containerStream == null) {
      debugPrint("$bookName ($bookUUID): Can't find container");
      return null;
    }

    final XmlDocument document = XmlDocument.parse(containerStream.readString());
    XmlElement? rootfile = document.findAllElements('rootfile').firstOrNull();
    if (rootfile == null) {
      debugPrint("$bookName ($bookUUID): Can't find rootfile");
      return null;
    }

    return rootfile.getAttributeNode("full-path")?.value;
  }

  images.Image? getCover() {
    if (bookUUID == "00a3950a-a1a6-4dc3-83b2-9e08572d8bab") {
      debugPrint('here');
    }
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
        coverName = _getCoverImageFromXhtml(coverName);
      } else if (coverName.endsWith('.html') || coverName.endsWith('.htm')) {
        coverName = _getCoverImageFromHtml(coverName);
      }
    }

    if (coverName != null) {
      if (coverName.startsWith('../')) {
        // TODO: I should normalise pathnames, but I suspect this will be enough given _findFileInArchive uses endsWith instead of ==
        coverName = coverName.replaceAll('../', '');
      }
      ArchiveFile? coverFile = _findFileInArchive(coverName);

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
