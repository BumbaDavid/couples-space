import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../profile/data/user_providers.dart';
import '../data/note.dart';
import '../data/shared_notes_providers.dart';
import 'note_editor_scope.dart';
import 'note_editor_screen.dart';

class SharedNotesScreen extends ConsumerWidget {
  const SharedNotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(sharedNotesProvider);
    final profile = ref.watch(currentUserProfileProvider).asData?.value;
    final coupleId = profile?.coupleId;
    final me = ref.watch(firebaseAuthProvider).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Shared notes')),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (notes) {
          if (notes.isEmpty) {
            return const Center(child: Text('No shared notes yet.'));
          }
          return ListView.separated(
            itemCount: notes.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) => _NoteTile(note: notes[i]),
          );
        },
      ),
      floatingActionButton: (coupleId == null || me == null)
          ? null
          : FloatingActionButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => NoteEditorScreen(
                    scope: SharedNoteScope(
                      coupleId: coupleId,
                      authorId: me.uid,
                    ),
                  ),
                ),
              ),
              child: const Icon(Icons.add),
            ),
    );
  }
}

class _NoteTile extends ConsumerWidget {
  const _NoteTile({required this.note});
  final Note note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authorAsync = ref.watch(userByIdProvider(note.authorId));
    final author = authorAsync.asData?.value?.displayName ?? '...';
    final relative = _relative(note.updatedAt);
    final profile = ref.watch(currentUserProfileProvider).asData?.value;
    final coupleId = profile?.coupleId;
    final me = ref.watch(firebaseAuthProvider).currentUser;

    return ListTile(
      title: Text(note.title.isEmpty ? '(Untitled)' : note.title),
      subtitle: Text(
        note.body.replaceAll('\n', ' '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text('$author · $relative',
          style: Theme.of(context).textTheme.bodySmall),
      onTap: (coupleId == null || me == null)
          ? null
          : () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => NoteEditorScreen(
                    scope: SharedNoteScope(
                      coupleId: coupleId,
                      authorId: me.uid,
                    ),
                    existing: note,
                  ),
                ),
              ),
    );
  }

  static String _relative(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat.yMMMd().format(when);
  }
}
