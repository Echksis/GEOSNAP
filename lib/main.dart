import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const HeroApp());
}

String apiBaseUrl = 'http://localhost/pahlawan_api';
Color primaryRed = Color(0xFF8B0000); // kept for existing CRUD/detail widgets

// Tema aplikasi dapat diganti dari menu Pengaturan.
enum AppThemeMode { cream, navy, dark }

final ValueNotifier<AppThemeMode> appThemeMode =
    ValueNotifier<AppThemeMode>(AppThemeMode.cream);

Color get cream => switch (appThemeMode.value) {
      AppThemeMode.cream => Color(0xFFF4EFE6),
      AppThemeMode.navy => Color(0xFFE8EEF2),
      AppThemeMode.dark => Color(0xFF101820),
    };

Color get navy => switch (appThemeMode.value) {
      AppThemeMode.cream => Color(0xFF182A3A),
      AppThemeMode.navy => Color(0xFF183247),
      AppThemeMode.dark => Color(0xFFF4EFE6),
    };

Color get terracotta => Color(0xFFA94736);
Color get gold => Color(0xFFC69A4B);
Color get darkBrown => switch (appThemeMode.value) {
      AppThemeMode.dark => Color(0xFFE8E1D7),
      _ => Color(0xFF302A25),
    };

Color get surfaceColor => switch (appThemeMode.value) {
      AppThemeMode.dark => Color(0xFF1B252D),
      _ => Colors.white,
    };

class HeroData {
  final int id;
  final String name;
  final String image;
  final String origin;
  final String lifetime;
  final String biography;

  HeroData({
    required this.id,
    required this.name,
    required this.image,
    required this.origin,
    required this.lifetime,
    required this.biography,
  });
}

class Comment {
  final int id;
  final int heroId;
  final String name;
  final String comment;
  final String createdAt;

  Comment({
    required this.id,
    required this.heroId,
    required this.name,
    required this.comment,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: int.tryParse('${json['id']}') ?? 0,
      heroId: int.tryParse('${json['hero_id']}') ?? 0,
      name: '${json['name'] ?? ''}',
      comment: '${json['comment'] ?? ''}',
      createdAt: '${json['created_at'] ?? ''}',
    );
  }
}

Future<List<HeroData>> fetchHeroes() async {
  final response = await http.get(Uri.parse('$apiBaseUrl/heroes.php'));

  if (response.statusCode != 200) {
    throw Exception('Gagal mengambil data. Status: ${response.statusCode}');
  }

  final decoded = jsonDecode(response.body);
  if (decoded is! List) {
    throw Exception('Format data pahlawan tidak valid.');
  }

  return decoded.map<HeroData>((item) {
    final data = Map<String, dynamic>.from(item as Map);
    return HeroData(
      id: int.tryParse('${data['id']}') ?? 0,
      name: '${data['name'] ?? ''}',
      image: 'assets/${data['image'] ?? ''}',
      origin: '${data['origin'] ?? ''}',
      lifetime: '${data['lifetime'] ?? ''}',
      biography: '${data['biography'] ?? ''}',
    );
  }).toList();
}

Future<bool> addHero({
  required String name,
  required String image,
  required String origin,
  required String lifetime,
  required String biography,
}) async {
  final response = await http.post(
    Uri.parse('$apiBaseUrl/add_hero.php'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'name': name,
      'image': image,
      'origin': origin,
      'lifetime': lifetime,
      'biography': biography,
    }),
  );

  if (response.statusCode != 200) return false;
  final result = jsonDecode(response.body);
  return result is Map && result['success'] == true;
}

Future<bool> updateHero({
  required int id,
  required String name,
  required String image,
  required String origin,
  required String lifetime,
  required String biography,
}) async {
  final response = await http.post(
    Uri.parse('$apiBaseUrl/update_hero.php'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'id': id,
      'name': name,
      'image': image,
      'origin': origin,
      'lifetime': lifetime,
      'biography': biography,
    }),
  );

  if (response.statusCode != 200) return false;
  final result = jsonDecode(response.body);
  return result is Map && result['success'] == true;
}

Future<bool> deleteHero(int id) async {
  final response = await http.post(
    Uri.parse('$apiBaseUrl/delete_hero.php'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'id': id}),
  );

  if (response.statusCode != 200) return false;
  final result = jsonDecode(response.body);
  return result is Map && result['success'] == true;
}

Future<List<Comment>> fetchComments(int heroId) async {
  final response = await http.get(
    Uri.parse('$apiBaseUrl/comments.php?hero_id=$heroId'),
  );

  if (response.statusCode != 200) {
    throw Exception('Gagal mengambil komentar.');
  }

  final result = jsonDecode(response.body);
  if (result is! Map || result['success'] != true) {
    throw Exception(
      result is Map
          ? '${result['message'] ?? 'Gagal mengambil komentar.'}'
          : 'Format komentar tidak valid.',
    );
  }

  final data = result['data'];
  if (data is! List) return [];

  return data.map<Comment>((item) {
    return Comment.fromJson(Map<String, dynamic>.from(item as Map));
  }).toList();
}

Future<bool> addComment({
  required int heroId,
  required String name,
  required String comment,
}) async {
  final response = await http.post(
    Uri.parse('$apiBaseUrl/comments.php'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'hero_id': heroId,
      'name': name,
      'comment': comment,
    }),
  );

  if (response.statusCode != 200) return false;
  final result = jsonDecode(response.body);
  return result is Map && result['success'] == true;
}

class HeroApp extends StatelessWidget {
  const HeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, mode, _) {
        final isDark = mode == AppThemeMode.dark;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Pahlawan Nasional',
          theme: ThemeData(
            brightness: isDark ? Brightness.dark : Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: terracotta,
              brightness: isDark ? Brightness.dark : Brightness.light,
            ),
            scaffoldBackgroundColor: cream,
            useMaterial3: true,
            fontFamily: 'Arial',
          ),
          home: const MainShell(),
        );
      },
    );
  }
}


// =========================
// APP SHELL & NEW UI
// =========================


class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    appThemeMode.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    appThemeMode.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        onOpenPahlawan: () => setState(() => currentIndex = 1),
        onOpenSejarah: () => setState(() => currentIndex = 2),
      ),
      PahlawanPage(),
      SejarahPage(),
      SettingsPage(),
    ];

    return Scaffold(
      backgroundColor: cream,
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        backgroundColor: cream,
        indicatorColor: terracotta.withValues(alpha: .14),
        onDestinationSelected: (index) => setState(() => currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Pahlawan'),
          NavigationDestination(icon: Icon(Icons.history_edu_outlined), selectedIcon: Icon(Icons.history_edu), label: 'Sejarah'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final VoidCallback? onOpenPahlawan;
  final VoidCallback? onOpenSejarah;

  const HomePage({super.key, this.onOpenPahlawan, this.onOpenSejarah});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<HeroData> heroes = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final result = await fetchHeroes();
      if (!mounted) return;
      setState(() {
        heroes = result;
        loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final choices = heroes.length > 8 ? heroes.take(8).toList() : heroes;

    return SafeArea(
      child: Container(
        child: RefreshIndicator(
          color: terracotta,
          onRefresh: load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(30, 24, 30, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PAHLAWAN', style: TextStyle(color: navy, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 3)),
                Text('INDONESIA', style: TextStyle(color: terracotta, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 20),
                _HomeHero(),
                const SizedBox(height: 30),
                _SectionTitle(title: 'Jelajahi Sejarah', subtitle: 'Kenali tokoh dan perjalanan yang membentuk Indonesia.'),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _StatBox(value: '${heroes.length}', label: 'Pahlawan', icon: Icons.people),
                    const SizedBox(width: 10),
                    _StatBox(value: '${heroes.map((h) => h.origin).toSet().length}', label: 'Daerah', icon: Icons.location_on),
                    const SizedBox(width: 10),
                    _StatBox(value: '1900+', label: 'Periode', icon: Icons.calendar_month),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: _SectionTitle(title: 'Pahlawan Pilihan', subtitle: 'Kenali lebih banyak tokoh perjuangan Indonesia.')),
                    TextButton(
                      onPressed: widget.onOpenPahlawan,
                      child: Text('Lihat semua', style: TextStyle(color: terracotta, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (loading)
                  const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()))
                else if (choices.isEmpty)
                  _HomeEmpty()
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 1100 ? 4 : constraints.maxWidth >= 700 ? 3 : 2;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: choices.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          mainAxisExtent: 205,
                        ),
                        itemBuilder: (context, index) {
                          final hero = choices[index];
                          return _FeaturedCard(
                            hero: hero,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage(hero: hero))),
                          );
                        },
                      );
                    },
                  ),
                const SizedBox(height: 26),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: widget.onOpenSejarah,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(color: terracotta, borderRadius: BorderRadius.circular(14)),
                          child: const Icon(Icons.history_edu, color: Colors.white),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('PERJALANAN SEJARAH', style: TextStyle(color: gold, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                          const SizedBox(height: 4),
                          const Text('Telusuri kisah dan perjuangan para pahlawan.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        ])),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 310,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 8))],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('images/home.jpg', fit: BoxFit.cover),
          Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x22000000), Color(0xD9182A3A)]))),
          Positioned(
            left: 26, bottom: 25,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(20)), child: const Text('MENGENANG PARA PAHLAWAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF182A3A)))),
              const SizedBox(height: 12),
              const Text('Jejak perjuangan mereka,\nmenjadi bagian dari Indonesia.', style: TextStyle(color: Colors.white, fontSize: 27, height: 1.05, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('Kenali kisah, perjuangan, dan warisan para pahlawan.', style: TextStyle(color: Colors.white70, fontSize: 13)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: navy, fontSize: 20, fontWeight: FontWeight.w900)),
        SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: Color(0xFF746D65), fontSize: 12, height: 1.4)),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _StatBox({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: appThemeMode.value == AppThemeMode.dark ? surfaceColor : Colors.white.withValues(alpha: .72),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Color(0xFFE1D7C9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: terracotta, size: 19),
            SizedBox(height: 8),
            Text(value, style: TextStyle(color: navy, fontSize: 19, fontWeight: FontWeight.w900)),
            Text(label, style: TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final HeroData hero;
  final VoidCallback onTap;
  const _FeaturedCard({required this.hero, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: 170,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xFFE1D7C9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Color(0xFFE9E2D8),
                child: Image.asset(hero.image, fit: BoxFit.contain),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hero.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: navy, fontWeight: FontWeight.w800, fontSize: 12)),
                  SizedBox(height: 3),
                  Text(hero.origin, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeEmpty extends StatelessWidget {
  const _HomeEmpty();
  @override
  Widget build(BuildContext context) => Container(
    height: 150,
    alignment: Alignment.center,
    child: Text('Belum ada data pahlawan.', style: TextStyle(color: Colors.grey)),
  );
}

class PahlawanPage extends StatefulWidget {
  final bool showBackButton;
  const PahlawanPage({super.key, this.showBackButton = false});

  @override
  State<PahlawanPage> createState() => _PahlawanPageState();
}

class _PahlawanPageState extends State<PahlawanPage> {
  String searchQuery = '';
  String selectedRegion = 'Semua';
  bool isLoading = true;
  String? errorMessage;
  List<HeroData> heroes = [];

  final List<String> regions = ['Semua', 'Jawa', 'Sumatera', 'Aceh', 'Sulawesi', 'Maluku', 'Bali', 'Papua'];

  @override
  void initState() {
    super.initState();
    loadHeroes();
  }

  Future<void> loadHeroes() async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final result = await fetchHeroes();
      if (!mounted) return;
      setState(() { heroes = result; isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { isLoading = false; errorMessage = e.toString(); });
    }
  }

  List<HeroData> get filteredHeroes {
    final query = searchQuery.trim().toLowerCase();
    return heroes.where((hero) {
      final matchesSearch = query.isEmpty || hero.name.toLowerCase().contains(query) || hero.origin.toLowerCase().contains(query);
      final matchesRegion = selectedRegion == 'Semua' || hero.origin.toLowerCase().contains(selectedRegion.toLowerCase());
      return matchesSearch && matchesRegion;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredHeroes;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 22, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showBackButton) ...[
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back),
                tooltip: 'Kembali',
              ),
              SizedBox(height: 2),
            ],
            Text('DAFTAR', style: TextStyle(color: navy, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 3)),
            Text('PAHLAWAN', style: TextStyle(color: terracotta, fontSize: 30, fontWeight: FontWeight.w900)),
            SizedBox(height: 5),
            Text('Kenali tokoh-tokoh yang berjasa dalam sejarah Indonesia.', style: TextStyle(color: Colors.grey, fontSize: 13)),
            SizedBox(height: 22),
            TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Cari nama atau daerah asal...',
                prefixIcon: Icon(Icons.search, color: terracotta),
                filled: true,
                fillColor: surfaceColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: Color(0xFFE1D7C9))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: terracotta, width: 1.5)),
              ),
            ),
            SizedBox(height: 13),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: regions.length,
                separatorBuilder: (_, _) => SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final region = regions[index];
                  final selected = selectedRegion == region;
                  return ChoiceChip(
                    label: Text(region),
                    selected: selected,
                    onSelected: (value) { if (value) setState(() => selectedRegion = region); },
                    selectedColor: navy,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(color: selected ? Colors.white : darkBrown, fontWeight: FontWeight.w700, fontSize: 11),
                    side: BorderSide(color: selected ? navy : Color(0xFFE1D7C9)),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            if (isLoading)
              Padding(padding: EdgeInsets.all(50), child: Center(child: CircularProgressIndicator(color: terracotta)))
            else if (errorMessage != null)
              _ErrorBox(onRetry: loadHeroes)
            else ...[
              Row(
                children: [
                  Text('${filtered.length} pahlawan', style: TextStyle(color: navy, fontSize: 13, fontWeight: FontWeight.w800)),
                  Spacer(),
                  if (searchQuery.isNotEmpty || selectedRegion != 'Semua')
                    TextButton(onPressed: () => setState(() { searchQuery = ''; selectedRegion = 'Semua'; }), child: Text('Reset', style: TextStyle(color: terracotta))),
                ],
              ),
              SizedBox(height: 8),
              if (filtered.isEmpty) _EmptyBox()
              else GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 230, crossAxisSpacing: 14, mainAxisSpacing: 14, mainAxisExtent: 235),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final hero = filtered[index];
                  return _HeroCard(
                    hero: hero,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage(hero: hero))),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SejarahPage extends StatefulWidget {
  final bool showBackButton;
  const SejarahPage({super.key, this.showBackButton = false});

  @override
  State<SejarahPage> createState() => _SejarahPageState();
}

class _SejarahPageState extends State<SejarahPage> {
  List<HeroData> heroes = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final result = await fetchHeroes();
      if (!mounted) return;
      setState(() { heroes = result; loading = false; });
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> openWikipedia(HeroData hero) async {
    final query = Uri.encodeComponent('${hero.name} pahlawan nasional Indonesia');
    final uri = Uri.parse('https://www.google.com/search?q=site%3Aid.wikipedia.org+$query');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak dapat membuka browser.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(30, 22, 30, 30),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (widget.showBackButton) IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
            Text('JEJAK', style: TextStyle(color: navy, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 3)),
            Text('SEJARAH', style: TextStyle(color: terracotta, fontSize: 30, fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            Text('Pilih seorang pahlawan untuk membaca kisah singkatnya.', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 24),
            if (loading)
              const Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator()))
            else if (heroes.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(50), child: Text('Data pahlawan belum tersedia.')))
            else
              ...heroes.map((hero) => _HistoryHeroCard(hero: hero, onWikipedia: () => openWikipedia(hero))),
          ]),
        ),
      ),
    );
  }
}

class _HistoryHeroCard extends StatefulWidget {
  final HeroData hero;
  final VoidCallback onWikipedia;
  const _HistoryHeroCard({required this.hero, required this.onWikipedia});

  @override
  State<_HistoryHeroCard> createState() => _HistoryHeroCardState();
}

class _HistoryHeroCardState extends State<_HistoryHeroCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final hero = widget.hero;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: appThemeMode.value == AppThemeMode.dark ? surfaceColor : Colors.white.withValues(alpha: .92), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE1D7C9))),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() => expanded = !expanded),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            Row(children: [
              ClipRRect(borderRadius: BorderRadius.circular(14), child: Container(width: 78, height: 78, color: const Color(0xFFF0ECE5), child: Image.asset(hero.image, fit: BoxFit.contain, errorBuilder: (_, _, _) => const Icon(Icons.broken_image)))),
              const SizedBox(width: 15),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(hero.name, style: TextStyle(color: navy, fontSize: 17, fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Text('${hero.origin} • ${hero.lifetime}', style: TextStyle(color: terracotta, fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 7),
                Text(expanded ? 'Tutup kisah' : 'Klik untuk membaca kisah singkat', style: TextStyle(color: appThemeMode.value == AppThemeMode.dark ? darkBrown : Colors.grey, fontSize: 11)),
              ])),
              Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: terracotta),
            ]),
            if (expanded) ...[
              const Divider(height: 28),
              Align(alignment: Alignment.centerLeft, child: Text('Kisah Singkat', style: TextStyle(color: navy, fontSize: 15, fontWeight: FontWeight.w900))),
              const SizedBox(height: 7),
              Align(alignment: Alignment.centerLeft, child: Text(hero.biography, style: TextStyle(color: darkBrown, fontSize: 13, height: 1.55))),
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerLeft, child: OutlinedButton.icon(onPressed: widget.onWikipedia, icon: const Icon(Icons.open_in_new, size: 16), label: const Text('Baca lebih jauh di Google / Wikipedia'))),
            ],
          ]),
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> openManage(BuildContext context) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => ManageHeroesPage()));
  }

  String _themeSubtitle() {
    switch (appThemeMode.value) {
      case AppThemeMode.cream:
        return 'Cream Heritage';
      case AppThemeMode.navy:
        return 'Navy Heritage';
      case AppThemeMode.dark:
        return 'Dark Mode';
    }
  }

  Future<void> _showThemePicker(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: cream,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tema Tampilan', style: TextStyle(color: navy, fontSize: 20, fontWeight: FontWeight.w900)),
                SizedBox(height: 6),
                Text('Pilih suasana tampilan aplikasi.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                SizedBox(height: 16),
                _ThemeOption(mode: AppThemeMode.cream, title: 'Cream Heritage', subtitle: 'Hangat dan bernuansa museum'),
                _ThemeOption(mode: AppThemeMode.navy, title: 'Navy Heritage', subtitle: 'Lebih tegas dengan nuansa navy'),
                _ThemeOption(mode: AppThemeMode.dark, title: 'Dark Mode', subtitle: 'Gelap untuk penggunaan malam'),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 22, 24, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PENGATURAN', style: TextStyle(color: navy, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 3)),
            Text('APLIKASI', style: TextStyle(color: terracotta, fontSize: 30, fontWeight: FontWeight.w900)),
            SizedBox(height: 5),
            Text('Kelola data dan informasi aplikasi.', style: TextStyle(color: Colors.grey, fontSize: 13)),
            SizedBox(height: 28),
            Text('DATA', style: TextStyle(color: gold, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
            SizedBox(height: 10),
            _SettingsTile(icon: Icons.people_alt_outlined, title: 'Kelola Pahlawan', subtitle: 'Tambah, edit, dan hapus data pahlawan', onTap: () => openManage(context)),
            SizedBox(height: 24),
            Text('TAMPILAN', style: TextStyle(color: gold, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
            SizedBox(height: 10),
            _SettingsTile(
              icon: Icons.palette_outlined,
              title: 'Tema Tampilan',
              subtitle: _themeSubtitle(),
              onTap: () => _showThemePicker(context),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  Icon(Icons.account_balance, color: gold, size: 28),
                  SizedBox(width: 14),
                  Expanded(child: Text('Kenali sejarah. Hargai perjuangan. Lanjutkan semangatnya.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, height: 1.4))),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final AppThemeMode mode;
  final String title;
  final String subtitle;

  const _ThemeOption({required this.mode, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final selected = appThemeMode.value == mode;
    final preview = switch (mode) {
      AppThemeMode.cream => Color(0xFFF4EFE6),
      AppThemeMode.navy => Color(0xFF183247),
      AppThemeMode.dark => Color(0xFF101820),
    };

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(color: preview, borderRadius: BorderRadius.circular(12)),
        child: Icon(Icons.palette_outlined, color: mode == AppThemeMode.cream ? terracotta : gold),
      ),
      title: Text(title, style: TextStyle(color: navy, fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey)),
      trailing: selected ? Icon(Icons.check_circle, color: terracotta) : Icon(Icons.circle_outlined, color: Colors.grey),
      onTap: () {
        appThemeMode.value = mode;
        Navigator.pop(context);
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _SettingsTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Color(0xFFE1D7C9)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(color: terracotta.withValues(alpha: .1), borderRadius: BorderRadius.circular(13)),
          child: Icon(icon, color: terracotta),
        ),
        title: Text(title, style: TextStyle(color: navy, fontWeight: FontWeight.w800, fontSize: 14)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey)),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorBox({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off, size: 50, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'Gagal mengambil data',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            'Pastikan Apache dan MySQL XAMPP sedang aktif.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: Text('Coba Lagi')),
        ],
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 55, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'Pahlawan tidak ditemukan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            'Coba gunakan kata kunci atau daerah lain.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class ManageHeroesPage extends StatefulWidget {
  const ManageHeroesPage({super.key});

  @override
  State<ManageHeroesPage> createState() => _ManageHeroesPageState();
}

class _ManageHeroesPageState extends State<ManageHeroesPage> {
  List<HeroData> data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      final result = await fetchHeroes();
      if (!mounted) return;
      setState(() {
        data = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data pahlawan.')),
      );
    }
  }

  Future<void> openForm({HeroData? hero}) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (context) => HeroFormDialog(hero: hero),
    );

    if (changed == true) await loadData();
  }

  Future<void> confirmDelete(HeroData hero) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Pahlawan?'),
        content: Text(
          'Data "${hero.name}" akan dihapus dari database. '
          'Komentar terkait juga akan ikut terhapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final success = await deleteHero(hero.id);
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pahlawan berhasil dihapus.')),
        );
        await loadData();
        if (mounted) Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus pahlawan.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kelola Pahlawan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: terracotta,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: loadData,
            icon: Icon(Icons.refresh),
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: terracotta,
        foregroundColor: Colors.white,
        onPressed: () => openForm(),
        icon: Icon(Icons.add),
        label: Text('Tambah'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: terracotta),
            )
          : data.isEmpty
              ? Center(child: Text('Belum ada data pahlawan.'))
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: data.length,
                  separatorBuilder: (context, index) =>
                      SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final hero = data[index];
                    return Card(
                      elevation: 1,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(10),
                        leading: Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Image.asset(
                            hero.image,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.image_not_supported),
                          ),
                        ),
                        title: Text(
                          hero.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${hero.origin} • ${hero.lifetime}'),
                        trailing: Wrap(
                          spacing: 2,
                          children: [
                            IconButton(
                              tooltip: 'Edit',
                              icon: Icon(Icons.edit, color: terracotta),
                              onPressed: () => openForm(hero: hero),
                            ),
                            IconButton(
                              tooltip: 'Hapus',
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () => confirmDelete(hero),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class HeroFormDialog extends StatefulWidget {
  final HeroData? hero;

  const HeroFormDialog({super.key, this.hero});

  @override
  State<HeroFormDialog> createState() => _HeroFormDialogState();
}

class _HeroFormDialogState extends State<HeroFormDialog> {
  late final TextEditingController nameController;
  late final TextEditingController imageController;
  late final TextEditingController originController;
  late final TextEditingController lifetimeController;
  late final TextEditingController biographyController;
  bool isSaving = false;

  bool get isEdit => widget.hero != null;

  @override
  void initState() {
    super.initState();
    final hero = widget.hero;
    nameController = TextEditingController(text: hero?.name ?? '');
    imageController = TextEditingController(
      text: hero == null ? '' : hero.image.replaceFirst('assets/', ''),
    );
    originController = TextEditingController(text: hero?.origin ?? '');
    lifetimeController = TextEditingController(text: hero?.lifetime ?? '');
    biographyController = TextEditingController(text: hero?.biography ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    imageController.dispose();
    originController.dispose();
    lifetimeController.dispose();
    biographyController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final name = nameController.text.trim();
    final image = imageController.text.trim();
    final origin = originController.text.trim();
    final lifetime = lifetimeController.text.trim();
    final biography = biographyController.text.trim();

    if ([name, image, origin, lifetime, biography]
        .any((value) => value.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Semua data harus diisi.')),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final success = isEdit
          ? await updateHero(
              id: widget.hero!.id,
              name: name,
              image: image,
              origin: origin,
              lifetime: lifetime,
              biography: biography,
            )
          : await addHero(
              name: name,
              image: image,
              origin: origin,
              lifetime: lifetime,
              biography: biography,
            );

      if (!mounted) return;

      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? 'Gagal memperbarui data.'
                  : 'Gagal menambahkan data.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  InputDecoration decoration(
    String label,
    IconData icon, {
    String? helperText,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      helperText: helperText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        isEdit ? 'Edit Pahlawan' : 'Tambah Pahlawan',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: decoration('Nama Pahlawan', Icons.person),
              ),
              SizedBox(height: 12),
              TextField(
                controller: imageController,
                decoration: decoration(
                  'Nama file gambar',
                  Icons.image,
                  helperText:
                      'Contoh: soekarno.jpg (file harus ada di assets/)',
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: originController,
                decoration: decoration('Daerah Asal', Icons.location_on),
              ),
              SizedBox(height: 12),
              TextField(
                controller: lifetimeController,
                decoration: decoration('Masa Hidup', Icons.calendar_today),
              ),
              SizedBox(height: 12),
              TextField(
                controller: biographyController,
                maxLines: 5,
                decoration: decoration(
                  'Biografi Singkat',
                  Icons.menu_book,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSaving ? null : () => Navigator.pop(context),
          child: Text('Batal'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: primaryRed),
          onPressed: isSaving ? null : save,
          icon: isSaving
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(Icons.save),
          label: Text(isSaving ? 'Menyimpan...' : 'Simpan'),
        ),
      ],
    );
  }
}

class _HeroCard extends StatefulWidget {
  final HeroData hero;
  final VoidCallback onTap;

  const _HeroCard({required this.hero, required this.onTap});

  @override
  State<_HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends State<_HeroCard> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) => setState(() => isHovering = true),
      onExit: (event) => setState(() => isHovering = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, isHovering ? -4 : 0, 0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: widget.onTap,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isHovering ? primaryRed : Colors.grey.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isHovering
                        ? Color(0x1F000000)
                        : Color(0x0A000000),
                    blurRadius: isHovering ? 12 : 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 125,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(14),
                      ),
                      child: Container(
                        color: Color(0xFFF0F0F0),
                        child: Image.asset(
                          widget.hero.image,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.hero.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 10,
                              color: isHovering ? primaryRed : Colors.grey,
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 11,
                              color: terracotta,
                            ),
                            SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                widget.hero.origin,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 10,
                              color: terracotta,
                            ),
                            SizedBox(width: 3),
                            Text(
                              widget.hero.lifetime,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DetailPage extends StatefulWidget {
  final HeroData hero;

  const DetailPage({super.key, required this.hero});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController commentController = TextEditingController();

  List<Comment> comments = [];
  bool isLoadingComments = true;
  bool isSending = false;
  String? commentError;

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  Future<void> loadComments() async {
    setState(() => isLoadingComments = true);

    try {
      final data = await fetchComments(widget.hero.id);
      if (!mounted) return;
      setState(() {
        comments = data;
        isLoadingComments = false;
        commentError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoadingComments = false;
        commentError = e.toString();
      });
    }
  }

  Future<void> submitComment() async {
    final name = nameController.text.trim();
    final comment = commentController.text.trim();

    if (name.isEmpty || comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nama dan komentar harus diisi.')),
      );
      return;
    }

    setState(() => isSending = true);

    try {
      final success = await addComment(
        heroId: widget.hero.id,
        name: name,
        comment: comment,
      );

      if (!mounted) return;

      if (success) {
        nameController.clear();
        commentController.clear();
        await loadComments();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Komentar berhasil ditambahkan.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan komentar.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      if (mounted) setState(() => isSending = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: terracotta,
        foregroundColor: Colors.white,
        title: Text(
          'Detail Pahlawan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 400,
              color: Colors.white,
              child: Image.asset(
                widget.hero.image,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 70,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.hero.name,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoBox(
                          icon: Icons.location_on,
                          title: 'Asal',
                          value: widget.hero.origin,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _InfoBox(
                          icon: Icons.calendar_today,
                          title: 'Life Time',
                          value: widget.hero.lifetime,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 28),
                  Text(
                    'Biografi Singkat',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.hero.biography,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 35),
                  Text(
                    'Komentar',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama',
                      hintText: 'Masukkan nama',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Komentar',
                      hintText: 'Tulis komentar kamu...',
                      prefixIcon: Icon(Icons.comment),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isSending ? null : submitComment,
                      icon: isSending
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(Icons.send),
                      label: Text(
                        isSending ? 'Mengirim...' : 'Kirim Komentar',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: terracotta,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Komentar Pengguna',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: loadComments,
                        tooltip: 'Muat ulang',
                        icon: Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  if (isLoadingComments)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(25),
                        child: CircularProgressIndicator(color: terracotta),
                      ),
                    )
                  else if (commentError != null)
                    _CommentErrorBox(onRetry: loadComments)
                  else if (comments.isEmpty)
                    _NoCommentBox()
                  else
                    ...comments.map(
                      (comment) => _CommentCard(comment: comment),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentErrorBox extends StatelessWidget {
  final VoidCallback onRetry;

  const _CommentErrorBox({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            'Komentar belum dapat dimuat.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          TextButton(onPressed: onRetry, child: Text('Coba Lagi')),
        ],
      ),
    );
  }
}

class _NoCommentBox extends StatelessWidget {
  const _NoCommentBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.chat_bubble_outline, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            'Belum ada komentar.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final Comment comment;

  const _CommentCard({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: terracotta,
                child: Icon(Icons.person, color: Colors.white, size: 18),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  comment.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            comment.comment,
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
          SizedBox(height: 8),
          Text(
            comment.createdAt,
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoBox({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: terracotta, size: 22),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
