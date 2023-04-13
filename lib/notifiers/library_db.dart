import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:synchronized/synchronized.dart';

import '../models/author.dart';
import '../models/book.dart';
import '../models/collection.dart';
import '../models/series.dart';
import '../models/tag.dart';

class LibraryDB extends ChangeNotifier {
  static final LibraryDB _instance = LibraryDB._internal();
  var lock = Lock();

  factory LibraryDB() {
    return _instance;
  }

  late Database _paladin;
  Map<String, int> tableCount = {'books' : 0, 'authors' : 0, 'tags' : 0, 'apps' : 0, 'settings' : 0};
  List<Tag> tags = [];
  Map<String, List<Collection>> collection = {};

  static const String _authors = '''
        create table if not exists authors(
          id integer primary key,
          name text not null,
          unique (name) on conflict ignore);
          ''';
  static const String _books = '''
        create table if not exists books(
          uuid text primary key,
          description text,
          path text not null,
          mimeType text not null,
          added integer not null,
          lastRead integer,
          rating integer,
          readStatus integer,
          series integer, 
          seriesIndex real,
          title text not null,
          unique(uuid) on conflict replace,
          foreign key(series) references series(id));
          ''';
  static const String _bookauthors = '''
        create table if not exists book_authors(
          authorId integer not null, 
          bookId text not null, 
          foreign key(authorId) references authors(id),
          foreign key(bookId) references books(uuid));
          ''';
  static const String _booktags = '''
        create table if not exists book_tags(
          bookId text not null, 
          tagId integer not null, 
          foreign key(bookId) REFERENCES books(uuid),
          foreign key(tagId) REFERENCES tags(id));
          ''';
  static const String _calibreserver = '''
        create table calibre_library (
					uuid text primary key,
					location text,
					calibre_version text,
					prefix text
					last_library_uuid text,
					last_connected date);
					''';
  static const String _series = '''
        create table if not exists series(
          id integer primary key,
          series text not null);
        ''';
  static const String _tags   = '''
        create table tags(
          id integer primary key,
          tag text not null,
          unique(tag) on conflict ignore);
          ''';
  static const String _indexAuthors     = 'create index authors_idx on authors(name);';
  static const String _indexBookauthors = 'create index book_authors_idx on book_authors(bookId, authorId);';
  static const String _indexTagname     = 'create index tagname_idx on tags(tag);';
  static const String _indexBooktags    = 'create index book_tags_idx on book_tags(bookId, tagId);';
  static const String _indexuuid        = 'create index bookuuid_idx on books(uuid);';
  static const String _indexSeriesname  = 'create index seriesname_idx on series(series);';
  static const String _indexLastread    = 'create index lastread_idx on books(lastRead);';
  static const String _indexAddeddate   = 'create index added_idx on books(added);';

  LibraryDB._internal() {
    _openDatabase();
  }

  Future<int> _createTables(Database db, int oldVersion, int newVersion) async {
    _enableForeignKeys(db);
    if (oldVersion < 1) {
      await db.execute(_authors);
      await db.execute(_series);
      await db.execute(_books);
      await db.execute(_bookauthors);
      await db.execute(_tags);
      await db.execute(_booktags);
      await db.execute(_calibreserver);

      await db.execute(_indexAuthors);
      await db.execute(_indexBookauthors);
      await db.execute(_indexTagname);
      await db.execute(_indexBooktags);
      await db.execute(_indexuuid);
      await db.execute(_indexSeriesname);
      await db.execute(_indexLastread);
      await db.execute(_indexAddeddate);
    }

    return -1;
  }

  Future _enableForeignKeys(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');
  }

  Future _getCurrentlyReading(Database db, Collection coll) async {
    final List<Map<String, dynamic>> maps = await _paladin.query('books', where: 'lastRead > 0', orderBy: 'lastRead DESC', limit: 10);
    collection[coll.getType()] = [];
    for (var map in maps) {
      collection[coll.getType()]!.add(await Book.fromMap(_paladin, map));
    }
  }

  Future<String> _getDatabasePath() async {
    String database = "";
    if (!kIsWeb) {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      database = documentsDirectory.path;
    }
    database += '/db/paladin.db';

    return database;
  }

  Future _getTableCount(Database db, String table) async {
    List<Map<String, Object?>> results = await db.rawQuery('select count(*) from $table');
    tableCount[table] = results[0].values.first as int;
  }

  void _openDatabase() async {
    sqfliteFfiInit();

    _paladin = await databaseFactoryFfi.openDatabase(await _getDatabasePath(),
        options: OpenDatabaseOptions(
            version: 1,
            onConfigure: (db) {
              _paladin = db;
              _enableForeignKeys(db);
            },
            onCreate: (db, version) {
              _createTables(db, 0, version);
            },
            onOpen: (db) async {
              await updateFields(db);
            },
            onUpgrade: (db, oldVersion, newVersion) {
              _createTables(db, oldVersion, newVersion);
            }));
  }

  Future _processResults(coll, maps) async {
    await lock.synchronized(() async {
      collection[coll.getType()] = [];
      for (var map in maps) {
        switch (coll.type) {
          case CollectionType.AUTHOR:
            collection[coll.getType()]!.add(Author.fromMap(map));
            break;
          case CollectionType.SERIES:
            collection[coll.getType()]!.add(Series.fromMap(map));
            break;
          case CollectionType.TAG:
            collection[coll.getType()]!.add(Tag.fromMap(map));
            break;
          default:
            collection[coll.getType()]!.add(await Book.fromMap(_paladin, map));
        }
      }
    });

    notifyListeners();
  }

  Future<List<Author>> getAuthors() async {
    final List<Map<String, dynamic>> maps = await _paladin.query('authors');
    return List.generate(maps.length, (i) {
      return Author.fromMap(maps[i]);
    });
  }

  Future getCollection(Collection coll) async {
    // This checked that the DB initialisation has completed and returns, if not.
    if (collection.isEmpty) {
      return;
    }
    debugPrint('getCollection: ${coll.getType()}, ${coll.query}');

    if (!collection.containsKey(coll.getType())) {
      if (coll.type == CollectionType.AUTHOR) {
        if (coll.query != null) {
          _paladin.rawQuery(coll.query!, coll.queryArgs).then((maps) => _processResults(coll, maps));
        } else {
          _paladin.rawQuery('''
            select * from books where uuid = (
            select uuid from book_authors, authors where book_authors.authorId = authors.id and authors.name = ?);)
            ''', [coll.getType()]).then((maps) => _processResults(coll, maps));
        }
      } else if (coll.type == CollectionType.BOOK) {
        if (coll.query != null) {
          _paladin.rawQuery(coll.query!, coll.queryArgs).then((maps) => _processResults(coll, maps));
        } else {
          _paladin.query('books', where: 'uuid = ?', whereArgs: [coll.getType()]).then((maps) => _processResults(coll, maps));
        }

      } else if (coll.type == CollectionType.CURRENT) {
        _paladin.query('books', where: 'lastRead > 0', orderBy: 'lastRead DESC', limit: 30).then((maps) => _processResults(coll, maps));

      } else if (coll.type == CollectionType.RANDOM) {
        _paladin.query('books', orderBy: 'RANDOM()', limit: 30).then((maps) => _processResults(coll, maps));

      } else if (coll.type == CollectionType.SERIES) {
        if (coll.query != null) {
          _paladin.rawQuery(coll.query!, coll.queryArgs).then((maps) => _processResults(coll, maps));
        } else {
          _paladin.rawQuery(
              'select * from books where series = (select id from series where series = ?)',
              [coll.getType()]).then((maps) => _processResults(coll, maps));
        }
      } else if (coll.type == CollectionType.TAG) {
        if (coll.query != null) {
          _paladin.rawQuery(coll.query!, coll.queryArgs).then((maps) => _processResults(coll, maps));
        } else {
          _paladin.rawQuery('''
            select * from books where uuid = (
            select uuid from book_tags, tags where book_tags.tagId = tags.id and tags.tag = ?);)
            ''', [coll.getType()]).then((maps) => _processResults(coll, maps));
        }
      }
    }
  }

  Future<void> insertBook(Book book) async {
    // Ensure we update the Added date if we don't already have it.
    book.added ??= (DateTime.now().millisecondsSinceEpoch / 1000).round();

    // Insert Series, returning foreign key for the Book.
    if (book.series != null) {
      if (book.series!.id == null) {
        List<Map> result = await _paladin.query('series', columns: ['id'], where: 'series = ?', whereArgs: [book.series!.series]);
        if (result.isNotEmpty) {
          book.series!.id = result.first['id'] as int;
        } else {
          book.series!.id = await _paladin.insert('series', book.series!.toMap());
        }
      }
    }

    // Now insert the Book.
    _paladin.insert('books', book.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

    // Insert all the Authors, updating the id for the next foreign key
    for (var author in book.authors!)  {
      List<Map> result = await _paladin.query('authors', columns: ['id'], where: 'name = ?', whereArgs: [author.name]);
      if (result.isNotEmpty) {
        author.id = result.first['id'] as int;
      }
      else {
        author.id = await _paladin.insert('authors', author.toMap());
      }
    }

    // Insert the many-many relationship into bookauthors.
    for (var author in book.authors!) {
      List<Map> result = await _paladin.query('book_authors', columns: ['authorId'], where: 'authorId = ? and bookId = ?', whereArgs: [author.id, book.uuid]);
      if (result.isEmpty) {
        _paladin.insert('book_authors', { 'authorId' : author.id, 'bookId' : book.uuid });
      }
    }

    // Insert all the Tags, updating the id for the next foreign key
    if (book.tags != null) {
      for (var tag in book.tags!) {
        List<Map> result = await _paladin.query('tags', columns: ['id'], where: 'tag = ?', whereArgs: [tag.tag]);
        if (result.isNotEmpty) {
          tag.id = result.first['id'] as int;
        }
        else {
          tag.id = await _paladin.insert('tags', tag.toMap());
        }
      }

      // Insert the many-many relationship into bookauthors.
      for (var tag in book.tags!) {
        List<Map> result = await _paladin.query('book_tags', columns: ['tagId'], where: 'tagId = ? and bookId = ?', whereArgs: [tag.id, book.uuid]);
        if (result.isEmpty) {
          _paladin.insert('book_tags', { 'tagId': tag.id, 'bookId': book.uuid});
        }
      }
    }
  }

  Future updateBook(Book book) async {
    book.lastRead = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    book.lastModified = book.lastRead;
    await _paladin.update('books', { 'lastRead' : book.lastRead, 'rating' : book.rating }, where: 'uuid = ?', whereArgs: [ book.uuid]);
    _getCurrentlyReading(_paladin, Collection(type: CollectionType.CURRENT));
  }

  Future updateFields(Database? db) async {
    db ??= _paladin;

    await _getTableCount(db, 'books');
    await _getTableCount(db, 'authors');
    await _getTableCount(db, 'series');
    await _getTableCount(db, 'tags');
    await _getCurrentlyReading(db, Collection(type: CollectionType.CURRENT));

    notifyListeners();
  }
}