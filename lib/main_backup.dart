import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const HeroApp());
}

const String apiBaseUrl = 'http://localhost/pahlawan_api';
const Color primaryRed = Color(0xFF8B0000);

class HeroData {
  final int id;
  final String name;
  final String image;
  final String origin;
  final String lifetime;
  final String biography;

  const HeroData({
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

  const Comment({
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pahlawan Nasional',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryRed),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String searchQuery = '';
  String selectedRegion = 'Semua';
  bool isLoading = true;
  String? errorMessage;
  List<HeroData> heroes = [];

  final List<String> regions = const [
    'Semua',
    'Jawa',
    'Sumatera',
    'Aceh',
    'Sulawesi',
    'Maluku',
    'Bali',
    'Papua',
  ];

  @override
  void initState() {
    super.initState();
    loadHeroes();
  }

  Future<void> loadHeroes() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await fetchHeroes();
      if (!mounted) return;
      setState(() {
        heroes = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  List<HeroData> get filteredHeroes {
    final query = searchQuery.trim().toLowerCase();

    return heroes.where((hero) {
      final matchesSearch =
          query.isEmpty ||
          hero.name.toLowerCase().contains(query) ||
          hero.origin.toLowerCase().contains(query);

      final matchesRegion =
          selectedRegion == 'Semua' ||
          hero.origin.toLowerCase().contains(selectedRegion.toLowerCase());

      return matchesSearch && matchesRegion;
    }).toList();
  }

  void resetFilter() {
    setState(() {
      searchQuery = '';
      selectedRegion = 'Semua';
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredHeroes;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'PAHLAWAN NASIONAL',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        actions: [
          IconButton(
            tooltip: 'Kelola Data',
            icon: const Icon(Icons.admin_panel_settings_outlined),
            onPressed: () async {
              final changed = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageHeroesPage(),
                ),
              );
              if (changed == true) loadHeroes();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: primaryRed,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0x26808080),
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: Icon(
                        Icons.account_balance,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Mengenal Pahlawan Indonesia',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Kenali tokoh-tokoh yang berjasa dalam sejarah perjuangan Indonesia.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daftar Pahlawan',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Data pahlawan dari database MySQL',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (searchQuery.isNotEmpty || selectedRegion != 'Semua')
                  TextButton(
                    onPressed: resetFilter,
                    child: const Text(
                      'Reset',
                      style: TextStyle(color: primaryRed),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 15),
            TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Cari nama atau daerah asal...',
                prefixIcon: const Icon(Icons.search, color: primaryRed),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => searchQuery = ''),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: primaryRed, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: regions.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final region = regions[index];
                  final selected = selectedRegion == region;
                  return ChoiceChip(
                    label: Text(region),
                    selected: selected,
                    onSelected: (value) {
                      if (value) setState(() => selectedRegion = region);
                    },
                    selectedColor: primaryRed,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    side: BorderSide(
                      color: selected ? primaryRed : Colors.grey.shade300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 15),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 50),
                child: Center(
                  child: CircularProgressIndicator(color: primaryRed),
                ),
              )
            else if (errorMessage != null)
              _ErrorBox(onRetry: loadHeroes)
            else ...[
              Text(
                '${filtered.length} pahlawan',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 10),
              if (filtered.isEmpty)
                const _EmptyBox()
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 215,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final hero = filtered[index];
                    return _HeroCard(
                      hero: hero,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(hero: hero),
                          ),
                        );
                      },
                    );
                  },
                ),
            ],
            const SizedBox(height: 20),
          ],
        ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off, size: 50, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'Gagal mengambil data',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pastikan Apache dan MySQL XAMPP sedang aktif.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
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
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
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
        const SnackBar(content: Text('Gagal mengambil data pahlawan.')),
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
        title: const Text('Hapus Pahlawan?'),
        content: Text(
          'Data "${hero.name}" akan dihapus dari database. '
          'Komentar terkait juga akan ikut terhapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
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
          const SnackBar(content: Text('Pahlawan berhasil dihapus.')),
        );
        await loadData();
        if (mounted) Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus pahlawan.')),
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
        title: const Text(
          'Kelola Pahlawan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: loadData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        onPressed: () => openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryRed),
            )
          : data.isEmpty
              ? const Center(child: Text('Belum ada data pahlawan.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final hero = data[index];
                    return Card(
                      elevation: 1,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
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
                                const Icon(Icons.image_not_supported),
                          ),
                        ),
                        title: Text(
                          hero.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${hero.origin} • ${hero.lifetime}'),
                        trailing: Wrap(
                          spacing: 2,
                          children: [
                            IconButton(
                              tooltip: 'Edit',
                              icon: const Icon(Icons.edit, color: primaryRed),
                              onPressed: () => openForm(hero: hero),
                            ),
                            IconButton(
                              tooltip: 'Hapus',
                              icon: const Icon(
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
        const SnackBar(content: Text('Semua data harus diisi.')),
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
        style: const TextStyle(fontWeight: FontWeight.bold),
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
              const SizedBox(height: 12),
              TextField(
                controller: imageController,
                decoration: decoration(
                  'Nama file gambar',
                  Icons.image,
                  helperText:
                      'Contoh: soekarno.jpg (file harus ada di assets/)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: originController,
                decoration: decoration('Daerah Asal', Icons.location_on),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lifetimeController,
                decoration: decoration('Masa Hidup', Icons.calendar_today),
              ),
              const SizedBox(height: 12),
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
          child: const Text('Batal'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: primaryRed),
          onPressed: isSaving ? null : save,
          icon: isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save),
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
        duration: const Duration(milliseconds: 180),
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
                        ? const Color(0x1F000000)
                        : const Color(0x0A000000),
                    blurRadius: isHovering ? 12 : 6,
                    offset: const Offset(0, 3),
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
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14),
                      ),
                      child: Container(
                        color: const Color(0xFFF0F0F0),
                        child: Image.asset(
                          widget.hero.image,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 10,
                              color: isHovering ? primaryRed : Colors.grey,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 11,
                              color: primaryRed,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                widget.hero.origin,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 10,
                              color: primaryRed,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              widget.hero.lifetime,
                              style: const TextStyle(
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
        const SnackBar(content: Text('Nama dan komentar harus diisi.')),
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
          const SnackBar(content: Text('Komentar berhasil ditambahkan.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambahkan komentar.')),
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
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        title: const Text(
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
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 70,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.hero.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoBox(
                          icon: Icons.location_on,
                          title: 'Asal',
                          value: widget.hero.origin,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoBox(
                          icon: Icons.calendar_today,
                          title: 'Life Time',
                          value: widget.hero.lifetime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Biografi Singkat',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.hero.biography,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 35),
                  const Text(
                    'Komentar',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama',
                      hintText: 'Masukkan nama',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Komentar',
                      hintText: 'Tulis komentar kamu...',
                      prefixIcon: const Icon(Icons.comment),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isSending ? null : submitComment,
                      icon: isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),
                      label: Text(
                        isSending ? 'Mengirim...' : 'Kirim Komentar',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      const Expanded(
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
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (isLoadingComments)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(25),
                        child: CircularProgressIndicator(color: primaryRed),
                      ),
                    )
                  else if (commentError != null)
                    _CommentErrorBox(onRetry: loadComments)
                  else if (comments.isEmpty)
                    const _NoCommentBox()
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off, size: 40, color: Colors.grey),
          const SizedBox(height: 8),
          const Text(
            'Komentar belum dapat dimuat.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextButton(onPressed: onRetry, child: const Text('Coba Lagi')),
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
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
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
              const CircleAvatar(
                radius: 17,
                backgroundColor: primaryRed,
                child: Icon(Icons.person, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  comment.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment.comment,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 8),
          Text(
            comment.createdAt,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
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
          Icon(icon, color: primaryRed, size: 22),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
