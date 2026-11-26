class Note {
  final int? id;
  final String title;
  final String content;
  final String category;
  final int color;
  final bool isFavorite;
  final String createdAt;
  final String updatedAt;

  const Note({
    this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.color,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
  });

  Note copyWith({
    int? id,
    String? title,
    String? content,
    String? category,
    int? color,
    bool? isFavorite,
    String? createdAt,
    String? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      color: color ?? this.color,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'content': content,
        'category': category,
        'color': color,
        'isFavorite': isFavorite ? 1 : 0,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  factory Note.fromMap(Map<String, dynamic> map) => Note(
        id: map['id'] as int,
        title: map['title'] as String,
        content: map['content'] as String,
        category: map['category'] as String,
        color: map['color'] as int,
        isFavorite: (map['isFavorite'] as int) == 1,
        createdAt: map['createdAt'] as String,
        updatedAt: map['updatedAt'] as String,
      );
}
