import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/note.dart';

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({super.key, this.note});
  final Note? note;

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _category = 'Personal';
  int _color = 0xFFFFF3C4;
  bool _favorite = false;

  static const categories = ['School', 'Personal', 'Work', 'Others'];
  static const colors = [
    0xFFFFF3C4,
    0xFFDDF4E4,
    0xFFDDEBFF,
    0xFFFFDFE7,
    0xFFECE1FF,
  ];

  @override
  void initState() {
    super.initState();
    final note = widget.note;
    if (note != null) {
      _titleController.text = note.title;
      _contentController.text = note.content;
      _category = note.category;
      _color = note.color;
      _favorite = note.isFavorite;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a title or note content')),
      );
      return;
    }

    final now = DateTime.now().toIso8601String();
    final existing = widget.note;
    final note = Note(
      id: existing?.id,
      title: title.isEmpty ? 'Untitled' : title,
      content: content,
      category: _category,
      color: _color,
      isFavorite: _favorite,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    if (existing == null) {
      await DatabaseHelper.instance.create(note);
    } else {
      await DatabaseHelper.instance.update(note);
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.note == null ? 'New note' : 'Edit note'),
        actions: [
          IconButton(
            tooltip: 'Favorite',
            onPressed: () => setState(() => _favorite = !_favorite),
            icon: Icon(_favorite ? Icons.star_rounded : Icons.star_border_rounded,
                color: _favorite ? const Color(0xFFE9A23B) : Colors.black54),
          ),
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Note title',
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contentController,
            minLines: 8,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: 'Write your note...',
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 18),
          const Text('Category', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((category) {
              final selected = _category == category;
              return ChoiceChip(
                label: Text(category),
                selected: selected,
                onSelected: (_) => setState(() => _category = category),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),
          const Text('Note color', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Row(
            children: colors.map((value) {
              final selected = _color == value;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => setState(() => _color = value),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Color(value),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? const Color(0xFF5B67F1) : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: selected
                        ? const Icon(Icons.check, size: 20, color: Color(0xFF5B67F1))
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
