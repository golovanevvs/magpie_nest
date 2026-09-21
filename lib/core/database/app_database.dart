import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:magpie_nest/core/database/sample_data.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DataClassName('FolderRow')
class Folders extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get parentId =>
      text().nullable().references(Folders, #id, onDelete: KeyAction.setNull)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SnippetRow')
class Snippets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get activeFragmentId => text().nullable()();
  TextColumn get folderId =>
      text().nullable().references(Folders, #id, onDelete: KeyAction.setNull)();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('FragmentRow')
class Fragments extends Table {
  TextColumn get id => text()();
  TextColumn get snippetId =>
      text().references(Snippets, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get language => text()();
  TextColumn get content => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Folders, Snippets, Fragments])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static const _databaseFolder = 'magpie nest';
  static const _databaseFilename = 'magpie_nest.sqlite';

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final directory = await _resolveDatabaseDirectory();
      return NativeDatabase(File(p.join(directory, _databaseFilename)));
    });
  }

  static Future<String> _resolveDatabaseDirectory() async {
    final supportDirectory = await getApplicationSupportDirectory();
    final directory = Directory(p.join(supportDirectory.path, _databaseFolder));
    await directory.create(recursive: true);
    return directory.path;
  }

  static Future<void> resetForDevelopment() async {
    if (!kDebugMode) return;
    const flag = bool.fromEnvironment('MAGPIE_NEST_RESET_DB');
    if (!flag) return;
    final support = await getApplicationSupportDirectory();
    final base = p.join(support.path, _databaseFolder, _databaseFilename);
    for (final suffix in ['', '-wal', '-shm']) {
      final file = File('$base$suffix');
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
        if (details.wasCreated) {
          await _seedSampleData();
        }
      },
    );
  }

  Future<void> _seedSampleData() async {
    for (final folder in sampleFolders()) {
      await into(folders).insert(
        FolderRow(
          id: folder.id,
          name: folder.name,
          parentId: folder.parentId,
          sortOrder: folder.sortOrder,
        ),
      );
    }

    for (final snippet in sampleSnippets()) {
      await into(snippets).insert(
        SnippetRow(
          id: snippet.id,
          name: snippet.name,
          description: snippet.description,
          activeFragmentId: snippet.activeFragmentId,
          folderId: snippet.folderId,
          isFavorite: snippet.isFavorite,
          isDeleted: snippet.isDeleted,
          createdAt: snippet.createdAt,
          updatedAt: snippet.updatedAt,
        ),
      );

      for (final fragment in snippet.fragments) {
        await into(fragments).insert(
          FragmentRow(
            id: fragment.id,
            snippetId: snippet.id,
            name: fragment.name,
            language: fragment.language,
            content: fragment.content,
            sortOrder: snippet.fragments.indexOf(fragment),
          ),
        );
      }
    }
  }
}
