import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:paladin/epub/epub_archive.dart';

import '../helpers/epub_fixture.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('epub_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  Epub openFixture(Map<String, List<int>> entries) {
    final path = '${tempDir.path}/book.epub';
    writeEpubFixture(path, {'META-INF/container.xml': containerXml.codeUnits, ...entries});
    return Epub(bookName: 'Test Book', bookPath: path, bookUUID: 'uuid-1', ref: testRef());
  }

  test('finds a cover referenced directly by a manifest item id', () {
    final coverBytes = sampleCoverJpegBytes();
    final epub = openFixture({
      'OEBPS/content.opf': '''
<package xmlns="http://www.idpf.org/2007/opf" version="2.0">
  <manifest>
    <item id="cover-image" href="cover.jpg" media-type="image/jpeg"/>
  </manifest>
  <spine></spine>
</package>
'''
          .codeUnits,
      'OEBPS/cover.jpg': coverBytes,
    });

    final cover = epub.getCover();

    expect(cover, isNotNull);
    expect(cover!.width, 4);
    expect(cover.height, 4);
  });

  test('recognises the "properties=cover-image" manifest attribute', () {
    final coverBytes = sampleCoverJpegBytes();
    final epub = openFixture({
      'OEBPS/content.opf': '''
<package xmlns="http://www.idpf.org/2007/opf" version="2.0">
  <manifest>
    <item id="img01" href="cover.jpg" media-type="image/jpeg" properties="cover-image"/>
  </manifest>
  <spine></spine>
</package>
'''
          .codeUnits,
      'OEBPS/cover.jpg': coverBytes,
    });

    expect(epub.getCover(), isNotNull);
  });

  test('follows an html wrapper page to find the cover image', () {
    final coverBytes = sampleCoverJpegBytes();
    final epub = openFixture({
      'OEBPS/content.opf': '''
<package xmlns="http://www.idpf.org/2007/opf" version="2.0">
  <manifest>
    <item id="cover" href="cover.html" media-type="application/xhtml+xml"/>
  </manifest>
  <spine></spine>
</package>
'''
          .codeUnits,
      'OEBPS/cover.html': '<html><body><img src="cover.jpg"/></body></html>'.codeUnits,
      'OEBPS/cover.jpg': coverBytes,
    });

    expect(epub.getCover(), isNotNull);
  });

  test('follows an xhtml wrapper page using epub:type="cover"', () {
    final coverBytes = sampleCoverJpegBytes();
    final epub = openFixture({
      'OEBPS/content.opf': '''
<package xmlns="http://www.idpf.org/2007/opf" version="2.0">
  <manifest>
    <item id="cover" href="cover.xhtml" media-type="application/xhtml+xml"/>
  </manifest>
  <spine></spine>
</package>
'''
          .codeUnits,
      'OEBPS/cover.xhtml': '''
<html xmlns:epub="http://www.idpf.org/2007/ops">
  <body>
    <section epub:type="cover"><img src="cover.jpg"/></section>
  </body>
</html>
'''
          .codeUnits,
      'OEBPS/cover.jpg': coverBytes,
    });

    expect(epub.getCover(), isNotNull);
  });

  test('falls back to the spine\'s first page when no cover item is declared', () {
    final coverBytes = sampleCoverJpegBytes();
    final epub = openFixture({
      'OEBPS/content.opf': '''
<package xmlns="http://www.idpf.org/2007/opf" version="2.0">
  <manifest>
    <item id="page1" href="page1.jpg" media-type="image/jpeg"/>
  </manifest>
  <spine>
    <itemref idref="page1"/>
  </spine>
</package>
'''
          .codeUnits,
      'OEBPS/page1.jpg': coverBytes,
    });

    expect(epub.getCover(), isNotNull);
  });

  test('returns null when neither a cover item nor a spine page can be found', () {
    final epub = openFixture({
      'OEBPS/content.opf': '''
<package xmlns="http://www.idpf.org/2007/opf" version="2.0">
  <manifest></manifest>
  <spine></spine>
</package>
'''
          .codeUnits,
    });

    expect(epub.getCover(), isNull);
  });

  test('returns null when the referenced cover file is missing from the archive', () {
    final epub = openFixture({
      'OEBPS/content.opf': '''
<package xmlns="http://www.idpf.org/2007/opf" version="2.0">
  <manifest>
    <item id="cover-image" href="missing.jpg" media-type="image/jpeg"/>
  </manifest>
  <spine></spine>
</package>
'''
          .codeUnits,
    });

    expect(epub.getCover(), isNull);
  });
}
