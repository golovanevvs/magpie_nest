import 'package:flutter_test/flutter_test.dart';
import 'package:magpie_nest/core/sync/webdav_credentials.dart';

void main() {
  group('default name', () {
    test('kDefaultSyncFolderName is magpie_nest', () {
      expect(kDefaultSyncFolderName, 'magpie_nest');
    });

    test('kDefaultJournalDir is derived from the folder name', () {
      expect(kDefaultJournalDir, 'magpie_nest/');
    });
  });

  group('normalizeParent', () {
    test('empty and whitespace map to root', () {
      expect(normalizeParent(''), '');
      expect(normalizeParent('   '), '');
    });

    test('strips leading and trailing slashes', () {
      expect(normalizeParent('Docs'), 'Docs');
      expect(normalizeParent('/Docs'), 'Docs');
      expect(normalizeParent('Docs/'), 'Docs');
      expect(normalizeParent('/Docs/'), 'Docs');
    });

    test('keeps nested parent path', () {
      expect(normalizeParent('a/b/'), 'a/b');
    });
  });

  group('isValidFolderName', () {
    test('accepts safe folder names', () {
      expect(isValidFolderName('magpie_nest'), isTrue);
      expect(isValidFolderName('2026'), isTrue);
      expect(isValidFolderName('my-folder'), isTrue);
      expect(isValidFolderName('a.b'), isTrue);
      expect(isValidFolderName('a--b'), isTrue);
    });

    test('rejects empty, traversal and reserved symbols', () {
      expect(isValidFolderName(''), isFalse);
      expect(isValidFolderName('a/b'), isFalse);
      expect(isValidFolderName(r'a\b'), isFalse);
      expect(isValidFolderName('..'), isFalse);
      expect(isValidFolderName('a..b'), isFalse);
      expect(isValidFolderName('my folder'), isFalse);
      expect(isValidFolderName('magpie_nest:2026'), isFalse);
      expect(isValidFolderName('.hidden'), isFalse);
      expect(isValidFolderName('name.'), isFalse);
    });
  });

  group('joinJournalDir', () {
    test('joins root parent with the folder name', () {
      expect(joinJournalDir('', 'magpie_nest'), 'magpie_nest/');
    });

    test('joins nested parent with the folder name', () {
      expect(joinJournalDir('Docs', 'magpie_nest'), 'Docs/magpie_nest/');
    });

    test('normalizes the parent before joining', () {
      expect(joinJournalDir('/Docs/', 'magpie_nest'), 'Docs/magpie_nest/');
    });
  });
}
