import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../shared_notes/data/note.dart';
import '../../shared_notes/ui/note_editor_scope.dart';
import '../../shared_notes/ui/note_editor_screen.dart';
import '../data/private_notes_providers.dart';

class PrivateNotesScreen extends ConsumerWidget {
  const PrivateNotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(firebaseAuthProvider).currentUser;
    if (me == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }
    final notesAsync = ref.watch(privateNotesProvider(me.uid));

    return Scaffold(
      appBar: AppBar(title: const Text('Private notes')),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (notes) {
          if (notes.isEmpty) {
            return const Center(child: Text('No private notes yet.'));
          }
          return ListView.separated(
            itemCount: notes.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) => _Tile(note: notes[i], userId: me.uid),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => NoteEditorScreen(
              scope: PrivateNoteScope(userId: me.uid),
            ),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.note, required this.userId});
  final Note note;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final relative = _relative(note.updatedAt);
    return ListTile(
      title: Text(note.title.isEmpty ? '(Untitled)' : note.title),
      subtitle: Text(
        note.body.replaceAll('\n', ' '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(relative, style: Theme.of(context).textTheme.bodySmall),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => NoteEditorScreen(
            scope: PrivateNoteScope(userId: userId),
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
