import 'package:magpie_nest/features/folders/domain/models/folder.dart';
import 'package:magpie_nest/features/snippets/domain/models/fragment.dart';
import 'package:magpie_nest/features/snippets/domain/models/snippet.dart';
import 'package:uuid/uuid.dart';

const folderWork = 'folder-work';
const folderPersonal = 'folder-personal';
const folderReact = 'folder-react';
const folderApi = 'folder-api';
const folderScripts = 'folder-scripts';

List<Folder> sampleFolders() {
  return const [
    Folder(id: folderWork, name: 'work', sortOrder: 0),
    Folder(id: folderPersonal, name: 'Personal', sortOrder: 1),
    Folder(
      id: folderReact,
      name: 'React Components',
      parentId: folderWork,
      sortOrder: 0,
    ),
    Folder(
      id: folderApi,
      name: 'API Calls',
      parentId: folderWork,
      sortOrder: 1,
    ),
    Folder(
      id: folderScripts,
      name: 'Scripts',
      parentId: folderPersonal,
      sortOrder: 0,
    ),
  ];
}

List<Snippet> sampleSnippets() {
  final now = DateTime.now();
  final snippetIds = {
    'dart': Uuid().v4(),
    'go': Uuid().v4(),
    'react': Uuid().v4(),
    'bash': Uuid().v4(),
    'note': Uuid().v4(),
    'old': Uuid().v4(),
  };

  return [
    Snippet(
      id: snippetIds['dart']!,
      name: 'Hello World in Dart',
      fragments: const [
        Fragment(
          id: 'frag-dart-main',
          name: 'main.dart',
          language: 'dart',
          content: 'void main() {\n  print(\'Hello, World!\');\n}',
        ),
      ],
      folderId: folderWork,
      isFavorite: true,
      createdAt: now.subtract(const Duration(days: 5)),
      updatedAt: now.subtract(const Duration(days: 5)),
    ),
    Snippet(
      id: snippetIds['go']!,
      name: 'HTTP Server in Go',
      fragments: const [
        Fragment(
          id: 'frag-go-main',
          name: 'main.go',
          language: 'go',
          content:
              'package main\n\nimport (\n    "fmt"\n    "net/http"\n)\n\nfunc handler(w http.ResponseWriter, r *http.Request) {\n    fmt.Fprintf(w, "Hello, World!")\n}\n\nfunc main() {\n    http.HandleFunc("/", handler)\n    http.ListenAndServe(":8080", nil)\n}',
        ),
      ],
      folderId: folderApi,
      createdAt: now.subtract(const Duration(days: 3)),
      updatedAt: now.subtract(const Duration(days: 3)),
    ),
    Snippet(
      id: snippetIds['react']!,
      name: 'React Button Component',
      fragments: const [
        Fragment(
          id: 'frag-react-button',
          name: 'Button.tsx',
          language: 'typescript',
          content:
              'import React from \'react\';\n\nexport const Button = ({ label, onClick }) => {\n  return <button onClick={onClick}>{label}</button>;\n};',
        ),
      ],
      folderId: folderReact,
      isFavorite: true,
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now.subtract(const Duration(days: 2)),
    ),
    Snippet(
      id: snippetIds['bash']!,
      name: 'Bash Backup Script',
      fragments: const [
        Fragment(
          id: 'frag-bash-backup',
          name: 'backup.sh',
          language: 'bash',
          content:
              '#!/bin/bash\nSOURCE_DIR="/home/user/documents"\nBACKUP_DIR="/backup"\nDATE=\$(date +%Y%m%d)\ntar -czf "\$BACKUP_DIR/backup_\$DATE.tar.gz" "\$SOURCE_DIR"',
        ),
      ],
      folderId: folderScripts,
      createdAt: now.subtract(const Duration(days: 1)),
      updatedAt: now.subtract(const Duration(days: 1)),
    ),
    Snippet(
      id: snippetIds['note']!,
      name: 'Quick Note',
      fragments: const [
        Fragment(
          id: 'frag-note-txt',
          name: 'note.txt',
          language: 'plaintext',
          content: '// TODO: Implement this feature later',
        ),
      ],
      createdAt: now,
      updatedAt: now,
    ),
    Snippet(
      id: snippetIds['old']!,
      name: 'Old Experiment',
      fragments: const [
        Fragment(
          id: 'frag-old-experiment',
          name: 'experiment.js',
          language: 'javascript',
          content: '// This was an old experiment\n// No longer needed',
        ),
      ],
      isDeleted: true,
      createdAt: now.subtract(const Duration(days: 10)),
      updatedAt: now.subtract(const Duration(days: 10)),
    ),
  ];
}
