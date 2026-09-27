import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as images;
import 'package:paladin/models/author.dart';
import 'package:paladin/models/book.dart';
import 'package:paladin/providers/cached_cover.dart';
import 'package:paladin/utils/application_path.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../helpers/epub_fixture.dart';
import '../helpers/fake_path_provider.dart';
import '../helpers/keep_alive.dart';

void main() {
  late Directory tempDir;
  late ProviderContainer container;

  const book = Book(
    uuid: 'uuid-1',
    authors: [Author(name: 'Butcher, Jim')],
    description: '',
    lastModified: 0,
    rating: 0,
    readStatus: false,
    tags: [],
    title: 'Brief Cases',
  );

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('cached_cover_test_');
    PathProviderPlatform.instance = FakePathProviderPlatform(tempDir.path);
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
    tempDir.deleteSync(recursive: true);
  });

  Future<void> writeBookFile(Book book, {required bool withCover}) async {
    final path = await book.path;
    writeEpubFixture(path, {
      'META-INF/container.xml': containerXml.codeUnits,
      'OEBPS/content.opf': '''
<package xmlns="http://www.idpf.org/2007/opf" version="2.0">
  <manifest>
    ${withCover ? '<item id="cover-image" href="cover.jpg" media-type="image/jpeg"/>' : ''}
  </manifest>
  <spine></spine>
</package>
'''
          .codeUnits,
      if (withCover) 'OEBPS/cover.jpg': sampleCoverJpegBytes(width: 40, height: 80),
    });
  }

  Future<File> coverCachePath(Book book) async {
    final appPath = await getApplicationPath();
    return File('$appPath/covers/${book.authors[0].name[0]}/${book.uuid}.jpg');
  }

  test('cacheCover writes a resized jpeg to the per-author cache path when the epub has a cover', () async {
    await writeBookFile(book, withCover: true);
    keepAlive(container, cachedCoverProvider(book));

    await container.read(cachedCoverProvider(book).notifier).cacheCover();

    final cacheFile = await coverCachePath(book);
    expect(cacheFile.existsSync(), isTrue);

    final decoded = images.decodeJpg(cacheFile.readAsBytesSync());
    expect(decoded, isNotNull);
    expect(decoded!.height, 200); // cacheCover() resizes to a fixed height.
  });

  test('cacheCover does nothing when the epub has no cover image', () async {
    await writeBookFile(book, withCover: false);
    keepAlive(container, cachedCoverProvider(book));

    await container.read(cachedCoverProvider(book).notifier).cacheCover();

    final cacheFile = await coverCachePath(book);
    expect(cacheFile.existsSync(), isFalse);
  });

  test('cacheCover does nothing when the book file has not been downloaded yet', () async {
    keepAlive(container, cachedCoverProvider(book));

    await container.read(cachedCoverProvider(book).notifier).cacheCover();

    final cacheFile = await coverCachePath(book);
    expect(cacheFile.existsSync(), isFalse);
  });

  test('build falls back to the generic cover art before caching has a chance to run', () async {
    // build() fires cacheCover() without awaiting it, so the very first
    // build always sees a cache miss and returns the generic fallback, even
    // for a book whose epub does have a real cover.
    await writeBookFile(book, withCover: true);
    keepAlive(container, cachedCoverProvider(book));

    final image = await container.read(cachedCoverProvider(book).future);

    expect(image.image, isA<AssetImage>());
  });

  test('build automatically upgrades to the cached file once caching completes, with no invalidation needed', () async {
    await writeBookFile(book, withCover: true);
    keepAlive(container, cachedCoverProvider(book));

    final firstImage = await container.read(cachedCoverProvider(book).future);
    expect(firstImage.image, isA<AssetImage>()); // first render: cache miss.

    // The fire-and-forget cacheCover() triggered by that first build should
    // finish shortly after and push the real cover in on its own.
    Image? upgraded;
    for (int i = 0; i < 20 && upgraded == null; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final value = container.read(cachedCoverProvider(book)).value;
      if (value != null && value.image is FileImage) upgraded = value;
    }

    expect(upgraded, isNotNull);
  });
}
