import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<bool> _saveAndExit() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty && body.isEmpty) {
      if (_persistedId != null) {
        await widget.scope.delete(noteId: _persistedId!, ref: ref);
      }
      return true;
    }
    if (_persistedId == null) {
      await widget.scope.create(title: title, body: body, ref: ref);
    } else {
      await widget.scope
          .update(noteId: _persistedId!, title: title, body: body, ref: ref);
    }
    return true;
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
    if (confirmed ?? false) {
      await widget.scope.delete(noteId: _persistedId!, ref: ref);
      if (mounted) nav.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final nav = Navigator.of(context);
        await _saveAndExit();
        if (mounted) nav.pop();
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
