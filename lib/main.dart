import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/note.dart';
import 'screens/note_detail_screen.dart';
import 'screens/note_editor_screen.dart';
import 'widgets/note_card.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NoteNestApp());
}

class NoteNestApp extends StatelessWidget {
  const NoteNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoteNest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B67F1)),
        scaffoldBackgroundColor: const Color(0xFFF8FAFD),
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final _homeKey = GlobalKey<_HomeScreenState>();
  final _favoritesKey = GlobalKey<_FavoritesScreenState>();
  final _categoriesKey = GlobalKey<_CategoriesScreenState>();

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(key: _homeKey),
      FavoritesScreen(key: _favoritesKey),
      CategoriesScreen(key: _categoriesKey),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              onPressed: () async {
                final changed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
                );
                if (changed == true) await _homeKey.currentState?.load();
              },
              child: const Icon(Icons.add_rounded),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() => _index = value);
          if (value == 0) _homeKey.currentState?.load();
          if (value == 1) _favoritesKey.currentState?.load();
          if (value == 2) _categoriesKey.currentState?.load();
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.star_outline_rounded), selectedIcon: Icon(Icons.star_rounded), label: 'Favorites'),
          NavigationDestination(icon: Icon(Icons.category_outlined), selectedIcon: Icon(Icons.category_rounded), label: 'Categories'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> _notes = [];
  String _search = '';

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final notes = _search.isEmpty
        ? await DatabaseHelper.instance.getNotes()
        : await DatabaseHelper.instance.search(_search);
    if (mounted) setState(() => _notes = notes);
  }

  Future<void> _openDetail(Note note) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note)),
    );
    if (changed == true) await load();
  }

  Future<void> _toggleFavorite(Note note) async {
    await DatabaseHelper.instance.update(note.copyWith(isFavorite: !note.isFavorite));
    await load();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: load,
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 44, height: 44,
                    decoration: BoxDecoration(color: const Color(0xFF5B67F1), borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.note_alt_rounded, color: Colors.white)),
                  const SizedBox(width: 12),
                  const Text('NoteNest', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 22),
                const Text('Welcome back!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Capture ideas before they fade.', style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 18),
                TextField(onChanged: (value) { _search = value; load(); }, decoration: InputDecoration(
                  hintText: 'Search notes...', prefixIcon: const Icon(Icons.search_rounded), filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),),
                const SizedBox(height: 20),
                const Text('Your notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
              ]),
            ),
          ),
          if (_notes.isEmpty)
            SliverToBoxAdapter(child: EmptyState(search: _search.isNotEmpty))
          else
            SliverPadding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 100), sliver: SliverList.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return NoteCard(note: note, onTap: () => _openDetail(note), onFavorite: () => _toggleFavorite(note));
              },
            ),),
        ]),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.search});
  final bool search;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(20, 50, 20, 20), child: Column(children: [
    const Icon(Icons.description_outlined, size: 64, color: Color(0xFFA9AFBC)),
    const SizedBox(height: 12),
    Text(search ? 'No matching notes' : 'No notes yet', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
    const SizedBox(height: 6),
    Text(search ? 'Try another search.' : 'Tap + to create your first note.', style: TextStyle(color: Colors.grey.shade600)),
  ]));
}

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Note> notes = [];
  @override
  void initState() { super.initState(); load(); }
  Future<void> load() async {
    final value = await DatabaseHelper.instance.getFavorites();
    if (mounted) setState(() => notes = value);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Favorites')),
    body: RefreshIndicator(onRefresh: load, child: notes.isEmpty
      ? ListView(children: const [Padding(padding: EdgeInsets.only(top: 120), child: Column(children: [
          Icon(Icons.star_border_rounded, size: 64, color: Color(0xFFA9AFBC)), SizedBox(height: 12),
          Text('No favorite notes', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        ]))])
      : ListView.builder(padding: const EdgeInsets.fromLTRB(20, 10, 20, 100), itemCount: notes.length,
          itemBuilder: (_, i) => NoteCard(note: notes[i],
            onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => NoteDetailScreen(note: notes[i]))); await load(); },
            onFavorite: () async { await DatabaseHelper.instance.update(notes[i].copyWith(isFavorite: false)); await load(); },))),
  );
}

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  static const categories = ['School', 'Personal', 'Work', 'Others'];
  List<Note> all = [];
  String selected = 'School';
  @override
  void initState() { super.initState(); load(); }
  Future<void> load() async {
    final value = await DatabaseHelper.instance.getNotes();
    if (mounted) setState(() => all = value);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = all.where((note) => note.category == selected).toList();
    return Scaffold(appBar: AppBar(title: const Text('Categories')), body: Column(children: [
      SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.fromLTRB(20, 8, 20, 10), child: Row(children: categories.map((category) => Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(
        label: Text(category), selected: selected == category, onSelected: (_) => setState(() => selected = category),
      ))).toList())),
      Expanded(child: filtered.isEmpty
        ? const Center(child: Text('No notes in this category'))
        : RefreshIndicator(onRefresh: load, child: ListView.builder(padding: const EdgeInsets.fromLTRB(20, 8, 20, 100), itemCount: filtered.length,
            itemBuilder: (_, i) => NoteCard(note: filtered[i],
              onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => NoteDetailScreen(note: filtered[i]))); await load(); },
              onFavorite: () async { await DatabaseHelper.instance.update(filtered[i].copyWith(isFavorite: !filtered[i].isFavorite)); await load(); },)))),
    ]));
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Settings')), body: ListView(padding: const EdgeInsets.all(20), children: [
    Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: const Row(children: [
      CircleAvatar(radius: 24, child: Icon(Icons.lock_outline_rounded)), SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Private & local', style: TextStyle(fontWeight: FontWeight.w800)), SizedBox(height: 4), Text('Your notes stay on this device.'),
      ])),
    ])),
    const SizedBox(height: 16),
    FutureBuilder<int>(future: DatabaseHelper.instance.getCount(), builder: (_, snapshot) => ListTile(
      tileColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      leading: const Icon(Icons.storage_rounded), title: const Text('SQLite storage'), subtitle: Text('${snapshot.data ?? 0} saved notes'),
    ),),
    const SizedBox(height: 16),
    const ListTile(tileColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
      leading: Icon(Icons.info_outline_rounded), title: Text('About NoteNest'), subtitle: Text('Version 1.0.0'),),
  ]));
}
