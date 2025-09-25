import 'package:archive/archive.dart';
import 'package:dartlin/collections.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as images;
import 'package:paladin/providers/status_provider.dart';
import 'package:xml/xml.dart';

class Epub {
  final String bookName;
  final String bookPath;
  final String bookUUID;
  final Ref ref;

  late Archive bookArchive;

  Epub({required this.bookName, required this.bookPath, required this.bookUUID, required this.ref}) {
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
    ArchiveFile? html = _findFileInArchive(coverName);
    if (html == null) {
      ref.read(statusProvider.notifier).addStatus("$bookName ($bookUUID): Can't find $coverName in epub!");
      return null;
    }

    try {
      XmlDocument htmlDocument = XmlDocument.parse(html.getContent()!.readString());

      XmlElement? coverAttribute = htmlDocument.findAllElements('image').firstOrNull();

      if (coverAttribute != null) {
        return coverAttribute.getAttribute('xlink:href');
      }

      // Option 2: <figure data-type="cover" id="bookcover01"><img src="cover.jpg"/></figure>
      coverAttribute = htmlDocument.findAllElements('figure')
          .where((item) => item.getAttribute('data-type')?.toLowerCase() == 'cover')
          .firstOrNull();
      if (coverAttribute != null) {
        coverAttribute = coverAttribute.findAllElements('img').firstOrNull();
        if (coverAttribute != null) {
          return coverAttribute.getAttribute('src');
        }
      }

      coverAttribute = htmlDocument.findAllElements('img').firstOrNull();
      if (coverAttribute != null) {
        return coverAttribute.getAttribute('src');
      }
    } on XmlTagException {
      if (ref.mounted) {
        ref.read(statusProvider.notifier).addStatus('$bookName ($bookUUID): Invalid XML in the epub. Try to fix with Sigil');
      }
      return null;
    }

    if (ref.mounted) {
      ref.read(statusProvider.notifier).addStatus("$bookName ($bookUUID): Can't find an image tag in the html");
    }
    return null;
  }

  String? _getCoverImageFromXhtml(String coverName) {
    ArchiveFile? xhtml = _findFileInArchive(coverName);
    if (xhtml == null) {
      ref.read(statusProvider.notifier).addStatus("$bookName ($bookUUID): Can't find $coverName in epub!");
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

    // Option 3. <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    //             <image width="600" height="800" xlink:href="cover.jpeg"/>
    //         </svg>
    coverAttribute = xhtmlDocument.findAllElements('svg').firstOrNull();
    if (coverAttribute != null) {
      XmlElement? coverImage = coverAttribute.findAllElements('image').firstOrNull();
      coverImage ??= coverAttribute.findAllElements('img').firstOrNull();

      if (coverImage != null) {
        String? coverFile = coverImage.getAttribute('xlink:href');
        coverFile ??= coverImage.getAttribute('href');

        if (coverFile != null) {
          return coverFile;
        }
      }
    }

    if (ref.mounted) {
      ref.read(statusProvider.notifier).addStatus("$bookName ($bookUUID): Can't find an image tag in the xhtml");
    }
    return null;
  }

  String? _getCoverName(XmlDocument opfContent) {
    List<XmlElement> coverElements = opfContent.findAllElements('item')
        .where((item) => item.getAttribute('id')?.toLowerCase() == 'cover-image'
        || item.getAttribute('id')?.toLowerCase() == 'my-cover-image'
        || item.getAttribute('id')?.toLowerCase() == 'cover'
        || item.getAttribute('id')?.toLowerCase() == 'cover1'
        || item.getAttribute('id')?.toLowerCase() == 'cov'
        || item.getAttribute('id')?.toLowerCase() == 'book-cover'
        || item.getAttribute('id')?.toLowerCase() == 'cover-jpg'
        || item.getAttribute('id')?.toLowerCase() == 'cover.jpg'
        || item.getAttribute('id')?.toLowerCase() == 'cover.jpeg'
        || item.getAttribute('id')?.toLowerCase() == 'img_cover'
        || item.getAttribute('id')?.toLowerCase() == 'coverimagestandard'
        || item.getAttribute('id')?.toLowerCase() == 'cover-page'
        || item.getAttribute('properties')?.toLowerCase() == 'cover-image').toList();

    if (coverElements.length == 1) {
      return coverElements.first.getAttribute('href');
    } else if (coverElements.length > 1) {
      try {
        return coverElements.firstWhere((element) {
          return element.getAttribute('href')!.endsWith('jpg') || element.getAttribute('href')!.endsWith('jpeg') || element.getAttribute('href')!.endsWith('png');
        }).getAttribute('href');
      } on StateError {
        return null;
      }
    } else {
      // Try the hard way - get the first page in the Spine and assume that contains the cover.
      XmlElement? spine = opfContent.findAllElements('spine').firstOrNull();
      spine ??= opfContent.findAllElements('opf:spine').firstOrNull();
      XmlElement? firstPage = spine?.findAllElements('itemref').firstOrNull();
      firstPage ??= spine?.findAllElements('opf:itemref').firstOrNull();
      String? pageRef = firstPage?.getAttribute('idref')!;

      if (pageRef != null) {
        XmlElement? page = opfContent.findAllElements('item')
            .where((item) => item.getAttribute('id')!.toLowerCase() == pageRef.toLowerCase())
            .firstOrNull();
        page ??= opfContent.findAllElements('opf:item')
            .where((item) => item.getAttribute('id')!.toLowerCase() == pageRef.toLowerCase())
            .firstOrNull();

        if (page != null) {
          return page.getAttribute('href');
        }
      }

      ref.read(statusProvider.notifier).addStatus('$bookName ($bookUUID) does not have a cover attribute.');
      return null;
    }
  }

  XmlDocument? _getOPFContent(String opfPath) {
    InputStream? opf = _findFileInArchive(opfPath)?.getContent();
    if (opf == null) {
      ref.read(statusProvider.notifier).addStatus("$bookName ($bookUUID): OPF file is empty!!!");
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
      ref.read(statusProvider.notifier).addStatus("$bookName ($bookUUID): Can't find container");
      return null;
    }

    final XmlDocument document = XmlDocument.parse(containerStream.readString());
    XmlElement? rootfile = document.findAllElements('rootfile').firstOrNull();
    if (rootfile == null) {
      ref.read(statusProvider.notifier).addStatus("$bookName ($bookUUID): Can't find rootfile");
      return null;
    }

    return rootfile.getAttributeNode("full-path")?.value;
  }

  images.Image? getCover() {
    String? opfPath = _getOPFPath();
    if (opfPath == null) {
      ref.read(statusProvider.notifier).addStatus("$bookName ($bookUUID): Can't find opfPath");

      return null;
    }

    final XmlDocument? opfContent = _getOPFContent(opfPath);
    if (opfContent == null) {
      ref.read(statusProvider.notifier).addStatus("$bookName ($bookUUID): Couldn't parse OPF content");
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
        ref.read(statusProvider.notifier).addStatus("$bookName ($bookUUID): Cover image ($coverName) doesn't exist!");
        return null;
      }

      return images.decodeImage(coverBytes);
    }

    return null;
  }

  void openBook() {
    final inputStream = InputFileStream(bookPath);
    bookArchive = ZipDecoder().decodeStream(inputStream);
    inputStream.closeSync();
  }
}
