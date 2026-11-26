// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:notenest/models/note.dart';

void main() {
  test('Note serializes for SQLite storage', () {
    const note = Note(
      id: 1,
      title: 'Test note',
      content: 'Local content',
      category: 'Personal',
      color: 0xFFFFF3C4,
      isFavorite: true,
      createdAt: '2026-11-26',
      updatedAt: '2026-11-26',
    );

    expect(note.toMap()['title'], 'Test note');
    expect(note.toMap()['isFavorite'], 1);
  });
}
