import 'package:flutter/material.dart';

import 'api_service.dart';
import 'add_report_page.dart';
import 'report.dart';
import 'reports_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Report>> _reportsFuture;

  static const Color primaryColor = Color(0xFF008F83);
  static const Color backgroundColor = Color(0xFFF3F8F7);
  static const Color textColor = Color(0xFF203534);

  @override
  void initState() {
    super.initState();
    _reportsFuture = ApiService.fetchReports();
  }

  Future<void> _refresh() async {
    final future = ApiService.fetchReports();

    setState(() {
      _reportsFuture = future;
    });

    try {
      await future;
    } catch (_) {
      // Error ditampilkan melalui FutureBuilder.
    }
  }

  Future<void> _addReport() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddReportPage(),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      await _refresh();
    }
  }

  Future<void> _openReports() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ReportsPage(),
      ),
    );

    if (!mounted) return;
    await _refresh();
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.blueGrey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          height: 155,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE5EEEC),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: accent,
                  size: 24,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: Colors.blueGrey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reportSummary() {
    return FutureBuilder<List<Report>>(
      future: _reportsFuture,
      builder: (context, snapshot) {
        String totalText;

        if (snapshot.connectionState == ConnectionState.waiting) {
          totalText = 'Memuat...';
        } else if (snapshot.hasError) {
          totalText = 'Gagal memuat';
        } else {
          totalText = '${snapshot.data?.length ?? 0} laporan';
        }

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE5EEEC),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F4F1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.article_rounded,
                  color: primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Laporan',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blueGrey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      totalText,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.trending_up_rounded,
                color: primaryColor.withValues(alpha: 0.8),
                size: 27,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _welcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 8,
            child: Icon(
              Icons.public_rounded,
              size: 85,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selamat datang di',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'GeoSnap',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Dokumentasikan dan laporkan apa saja dengan mudah.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _addReport,
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Buat Laporan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tipsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F3F1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: Color(0xFF08766F),
            size: 23,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tips: Tambahkan foto, deskripsi, dan lokasi agar laporan lebih mudah dipahami.',
              style: TextStyle(
                color: Color(0xFF35615D),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.photo_camera_back_rounded),
            SizedBox(width: 10),
            Text(
              'GeoSnap',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _refresh,
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            _welcomeBanner(),

            const SizedBox(height: 24),

            _sectionTitle(
              'Ringkasan',
              'Aktivitas laporan di GeoSnap',
            ),

            _reportSummary(),

            const SizedBox(height: 24),

            _sectionTitle(
              'Akses Cepat',
              'Pilih aktivitas yang ingin dilakukan',
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _actionCard(
                    icon: Icons.add_a_photo_rounded,
                    title: 'Buat Laporan',
                    subtitle: 'Tambahkan laporan baru dengan foto dan GPS',
                    accent: primaryColor,
                    onTap: _addReport,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _actionCard(
                    icon: Icons.folder_open_rounded,
                    title: 'Daftar Laporan',
                    subtitle: 'Lihat dan kelola laporan yang tersimpan',
                    accent: const Color(0xFF3977A5),
                    onTap: _openReports,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            _tipsCard(),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}