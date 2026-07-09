import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../private_notes/data/private_notes_providers.dart';
import '../data/shared_notes_providers.dart';

sealed class NoteEditorScope {
  Future<String> create({required String title, required String body, required WidgetRef ref});
  Future<void> update({
    required String noteId,
    required String title,
    required String body,
    required WidgetRef ref,
  });
  Future<void> delete({required String noteId, required WidgetRef ref});
}

class SharedNoteScope extends NoteEditorScope {
  SharedNoteScope({required this.coupleId, required this.authorId});
  final String coupleId;
  final String authorId;

  @override
  Future<String> create({
    required String title,
    required String body,
    required WidgetRef ref,
  }) {
    return ref.read(sharedNotesRepositoryProvider).createNote(
          coupleId: coupleId,
          title: title,
          body: body,
          authorId: authorId,
        );
  }

  @override
  Future<void> update({
    required String noteId,
    required String title,
    required String body,
    required WidgetRef ref,
  }) {
    return ref.read(sharedNotesRepositoryProvider).updateNote(
          coupleId: coupleId,
          noteId: noteId,
          title: title,
          body: body,
        );
  }

  @override
  Future<void> delete({required String noteId, required WidgetRef ref}) {
    return ref
        .read(sharedNotesRepositoryProvider)
        .deleteNote(coupleId: coupleId, noteId: noteId);
  }
}

class PrivateNoteScope extends NoteEditorScope {
  PrivateNoteScope({required this.userId});
  final String userId;

  @override
  Future<String> create({
    required String title,
    required String body,
    required WidgetRef ref,
  }) {
    return ref
        .read(privateNotesRepositoryProvider)
        .createNote(userId: userId, title: title, body: body);
  }

  @override
  Future<void> update({
    required String noteId,
    required String title,
    required String body,
    required WidgetRef ref,
  }) {
    return ref.read(privateNotesRepositoryProvider).updateNote(
          userId: userId,
          noteId: noteId,
          title: title,
          body: body,
        );
  }

  @override
  Future<void> delete({required String noteId, required WidgetRef ref}) {
    return ref
        .read(privateNotesRepositoryProvider)
        .deleteNote(userId: userId, noteId: noteId);
  }
}
