import 'package:magpie_nest/features/snippets/domain/models/fragment.dart';
import 'package:magpie_nest/features/snippets/domain/models/snippet.dart';
import 'package:magpie_nest/features/snippets/domain/repositories/i_snippet_repository.dart';
import 'package:uuid/uuid.dart';

class InMemorySnippetRepository implements ISnippetRepository {
  final List<Snippet> _snippets = [
    Snippet(
      id: const Uuid().v4(),
      name: 'Hello World in Dart',
      fragments: const [
        Fragment(
          id: '1',
          name: 'main.dart',
          language: 'dart',
          content: '''void main() {
  print('Hello, World!');
}''',
        ),
      ],
      folderId: 'folder-work',
      tags: const ['beginner', 'console'],
      isFavorite: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Snippet(
      id: const Uuid().v4(),
      name: 'HTTP Server in Go',
      fragments: const [
        Fragment(
          id: '1',
          name: 'main.go',
          language: 'go',
          content: '''package main

import (
    "fmt"
    "net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, "Hello, World!")
}

func main() {
    http.HandleFunc("/", handler)
    http.ListenAndServe(":8080", nil)
}''',
        ),
      ],
      folderId: 'folder-api',
      tags: const ['backend', 'networking'],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Snippet(
      id: const Uuid().v4(),
      name: 'React Button Component',
      fragments: const [
        Fragment(
          id: '1',
          name: 'Button.tsx',
          language: 'typescript',
          content: '''import React from 'react';

interface ButtonProps {
  label: string;
  onClick: () => void;
  variant?: 'primary' | 'secondary';
}

export const Button: React.FC<ButtonProps> = ({ 
  label, 
  onClick, 
  variant = 'primary' 
}) => {
  return (
    <button 
      className={`btn btn-\${variant}`}
      onClick={onClick}
    >
      {label}
    </button>
  );
};''',
        ),
      ],
      folderId: 'folder-react',
      tags: const ['react', 'component', 'ui'],
      isFavorite: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Snippet(
      id: const Uuid().v4(),
      name: 'Bash Backup Script',
      fragments: const [
        Fragment(
          id: '1',
          name: 'backup.sh',
          language: 'bash',
          content: '''#!/bin/bash

# Backup script
SOURCE_DIR="/home/user/documents"
BACKUP_DIR="/backup"
DATE=\$(date +%Y%m%d)

tar -czf "\$BACKUP_DIR/backup_\$DATE.tar.gz" "\$SOURCE_DIR"

echo "Backup completed: backup_\$DATE.tar.gz"''',
        ),
      ],
      folderId: 'folder-scripts',
      tags: const ['automation', 'backup'],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Snippet(
      id: const Uuid().v4(),
      name: 'Quick Note',
      fragments: const [
        Fragment(
          id: '1',
          name: 'note.txt',
          language: 'plaintext',
          content: '''// TODO: Implement this feature later
// Remember to check the API documentation''',
        ),
      ],
      tags: const ['note', 'todo'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Snippet(
      id: const Uuid().v4(),
      name: 'Old Experiment',
      fragments: const [
        Fragment(
          id: '1',
          name: 'experiment.js',
          language: 'javascript',
          content: '''// This was an old experiment
// No longer needed''',
        ),
      ],
      isDeleted: true,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  @override
  Future<List<Snippet>> getAllSnippets() async {
    return List.unmodifiable(_snippets);
  }

  @override
  Future<Snippet?> getSnippetById(String id) async {
    try {
      return _snippets.firstWhere((snippet) => snippet.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Snippet>> getSnippetsByFolderId(String? folderId) async {
    return _snippets.where((snippet) => snippet.folderId == folderId).toList();
  }

  @override
  Future<List<Snippet>> getFavoriteSnippets() async {
    return _snippets.where((snippet) => snippet.isFavorite).toList();
  }

  @override
  Future<List<Snippet>> getDeletedSnippets() async {
    return _snippets.where((snippet) => snippet.isDeleted).toList();
  }

  @override
  Future<void> saveSnippet(Snippet snippet) async {
    final index = _snippets.indexWhere((s) => s.id == snippet.id);
    if (index >= 0) {
      _snippets[index] = snippet;
    } else {
      _snippets.add(snippet);
    }
  }

  @override
  Future<void> deleteSnippet(String id) async {
    final index = _snippets.indexWhere((snippet) => snippet.id == id);
    if (index >= 0) {
      _snippets[index] = _snippets[index].copyWith(
        isDeleted: true,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> restoreSnippet(String id) async {
    final index = _snippets.indexWhere((snippet) => snippet.id == id);
    if (index >= 0) {
      _snippets[index] = _snippets[index].copyWith(
        isDeleted: false,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> permanentlyDeleteSnippet(String id) async {
    _snippets.removeWhere((snippet) => snippet.id == id);
  }
}
