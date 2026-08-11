import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_snack.dart';
import '../data/note.dart';
import 'note_editor_scope.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({super.key, required this.scope, this.existing});

  final NoteEditorScope scope;
  final Note? existing;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  String? _persistedId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title ?? '');
    _bodyController = TextEditingController(text: widget.existing?.body ?? '');
    _persistedId = widget.existing?.id;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  /// Fires the auto-save without being awaited by the caller.
  ///
  /// Every branch here is a Firestore write, which lands in the local cache
  /// immediately but only completes its Future on server acknowledgement.
  /// Awaiting it before popping meant the back gesture did nothing visible
  /// until the network replied — on a bad connection, seemingly not at all.
  /// Text is captured up-front because the controllers are disposed as soon as
  /// this screen pops.
  void _startSave(ScaffoldMessengerState messenger) {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    final id = _persistedId;
    final scope = widget.scope;

    Future<void> run() async {
      if (title.isEmpty && body.isEmpty) {
        // An empty note is discarded rather than saved.
        if (id != null) await scope.delete(noteId: id, ref: ref);
        return;
      }
      if (id == null) {
        await scope.create(title: title, body: body, ref: ref);
      } else {
        await scope.update(noteId: id, title: title, body: body, ref: ref);
      }
    }

    run().catchError((_) {
      AppSnack.errorOn(messenger, "Couldn't save that note.");
    });
  }

  Future<void> _confirmDelete() async {
    final nav = Navigator.of(context);
    if (_persistedId == null) {
      nav.pop();
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if ((confirmed ?? false) && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      final id = _persistedId!;
      final scope = widget.scope;
      // Leave first; the delete is applied locally at once.
      nav.pop();
      try {
        await scope.delete(noteId: id, ref: ref);
        AppSnack.showOn(messenger, 'Note deleted');
      } catch (_) {
        AppSnack.errorOn(messenger, "Couldn't delete that note.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        // Pop immediately and let the save run in the background — the note
        // list updates from the local cache, so waiting buys nothing.
        _startSave(ScaffoldMessenger.of(context));
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.existing == null ? 'New note' : 'Edit note'),
          actions: [
            if (widget.existing != null)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _confirmDelete,
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TextField(
                  controller: _bodyController,
                  decoration: const InputDecoration(
                    labelText: 'Body',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
