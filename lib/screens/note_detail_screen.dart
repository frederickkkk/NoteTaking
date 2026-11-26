import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/note.dart';
import 'note_editor_screen.dart';

class NoteDetailScreen extends StatefulWidget {
  const NoteDetailScreen({super.key, required this.note});
  final Note note;

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late Note note;

  @override
  void initState() {
    super.initState();
    note = widget.note;
  }

  Future<void> _toggleFavorite() async {
    note = note.copyWith(isFavorite: !note.isFavorite);
    await DatabaseHelper.instance.update(note);
    setState(() {});
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text('This note will be permanently removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseHelper.instance.delete(note.id!);
      if (mounted) Navigator.pop(context, true);
    }
  }

  Future<void> _edit() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)),
    );
    if (changed == true) {
      final notes = await DatabaseHelper.instance.getNotes();
      final updated = notes.where((item) => item.id == note.id).firstOrNull;
      if (updated != null && mounted) setState(() => note = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(note.updatedAt);
    return Scaffold(
      backgroundColor: Color(note.color),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(onPressed: _toggleFavorite,
              icon: Icon(note.isFavorite ? Icons.star_rounded : Icons.star_border_rounded)),
          IconButton(onPressed: _delete, icon: const Icon(Icons.delete_outline_rounded)),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 100),
          children: [
            Text(note.title,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, height: 1.2)),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(note.category),
                ),
                const SizedBox(width: 10),
                Text(date == null ? '' : DateFormat('MMM d, y • h:mm a').format(date),
                    style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
            const SizedBox(height: 28),
            Text(note.content.isEmpty ? 'No additional content.' : note.content,
                style: const TextStyle(fontSize: 17, height: 1.65)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _edit,
        icon: const Icon(Icons.edit_rounded),
        label: const Text('Edit'),
      ),
    );
  }
}
