import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:magpie_nest/core/database/sample_data.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

part 'app_database.g.dart';

@DataClassName('FolderRow')
class Folders extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get parentId =>
      text().nullable().references(Folders, #id, onDelete: KeyAction.setNull)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get revision => integer().withDefault(const Constant(0))();

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
  IntColumn get revision => integer().withDefault(const Constant(0))();
  DateTimeColumn get deletedAt => dateTime().nullable()();

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
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get revision => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SyncMetaRow')
class SyncMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Folders, Snippets, Fragments, SyncMeta])
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
        await _ensureDeviceId();
      },
    );
  }

  Future<String> getDeviceId() async {
    await _ensureDeviceId();
    final row = await (select(
      syncMeta,
    )..where((r) => r.key.equals('deviceId'))).getSingle();
    return row.value!;
  }

  Future<void> _ensureDeviceId() async {
    final existing = await (select(
      syncMeta,
    )..where((row) => row.key.equals('deviceId'))).getSingleOrNull();
    if (existing != null) return;
    await into(syncMeta).insert(
      SyncMetaRow(key: 'deviceId', value: const Uuid().v4()),
      mode: InsertMode.insertOrIgnore,
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
          createdAt: folder.createdAt,
          updatedAt: folder.updatedAt,
          isDeleted: folder.isDeleted,
          deletedAt: folder.deletedAt,
          revision: folder.revision,
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
          deletedAt: snippet.deletedAt,
          revision: snippet.revision,
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
            updatedAt: fragment.updatedAt,
            isDeleted: fragment.isDeleted,
            deletedAt: fragment.deletedAt,
            sortOrder: snippet.fragments.indexOf(fragment),
            revision: fragment.revision,
          ),
        );
      }
    }
  }
}
