import 'dart:convert';

import 'package:flutter/material.dart';

import 'api_service.dart';
import 'add_report_page.dart';
import 'detail_page.dart';
import 'report.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late Future<List<Report>> _reportsFuture;
  final Set<int> _deletingIds = {};

  static const Color primaryColor = Color(0xFF008F83);
  static const Color backgroundColor = Color(0xFFF3F8F7);

  @override
  void initState() {
    super.initState();
    _reportsFuture = ApiService.fetchReports();
  }

  Future<void> _loadReports() async {
    final future = ApiService.fetchReports();

    setState(() {
      _reportsFuture = future;
    });

    try {
      await future;
    } catch (_) {
      // Error ditampilkan oleh FutureBuilder.
    }
  }

  Future<void> _openAddReport() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddReportPage(),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      await _loadReports();
    }
  }

  Future<void> _openDetail(Report report) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(report: report),
      ),
    );
  }

  Future<void> _deleteReport(Report report) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Laporan'),
          content: Text(
            'Yakin ingin menghapus laporan "${report.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    setState(() {
      _deletingIds.add(report.id);
    });

    try {
      await ApiService.deleteReport(report.id);

      if (!mounted) return;

      await _loadReports();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil dihapus.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus laporan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _deletingIds.remove(report.id);
        });
      }
    }
  }

  Widget _buildReportImage(Report report) {
    try {
      final image = report.image
          .replaceAll(RegExp(r'\s'), '')
          .replaceFirst(
            RegExp(r'^data:image/[^;]+;base64,'),
            '',
          );

      if (image.isEmpty) {
        return _imagePlaceholder();
      }

      return Image.memory(
        base64Decode(image),
        height: 190,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _imagePlaceholder();
        },
      );
    } catch (_) {
      return _imagePlaceholder();
    }
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 190,
      width: double.infinity,
      color: const Color(0xFFE7EEEC),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 48,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildReportCard(Report report) {
    final isDeleting = _deletingIds.contains(report.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian foto dan isi kartu dapat diklik.
          InkWell(
            onTap: () => _openDetail(report),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReportImage(report),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF203534),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        report.category,
                        style: const TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        report.description.isEmpty
                            ? 'Tidak ada deskripsi.'
                            : report.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Color(0xFF526260),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 17,
                            color: Colors.blueGrey,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              '${report.latitude}, ${report.longitude}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        report.createdAt,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tombol hapus terpisah agar tidak membuka detail.
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: [
                const Icon(
                  Icons.touch_app_outlined,
                  size: 16,
                  color: Colors.blueGrey,
                ),
                const SizedBox(width: 5),
                const Expanded(
                  child: Text(
                    'Ketuk untuk melihat detail',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Hapus laporan',
                  onPressed: isDeleting
                      ? null
                      : () => _deleteReport(report),
                  icon: isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 56,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            const Text(
              'Gagal memuat laporan',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadReports,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.folder_open_outlined,
              size: 72,
              color: Colors.grey,
            ),
            const SizedBox(height: 14),
            const Text(
              'Belum ada laporan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Buat laporan pertamamu dengan menekan tombol +.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _openAddReport,
              icon: const Icon(Icons.add),
              label: const Text('Buat Laporan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Daftar Laporan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadReports,
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      body: FutureBuilder<List<Report>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildError(snapshot.error!);
          }

          final reports = snapshot.data ?? [];

          if (reports.isEmpty) {
            return _buildEmpty();
          }

          return RefreshIndicator(
            onRefresh: _loadReports,
            color: primaryColor,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                return _buildReportCard(reports[index]);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddReport,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        tooltip: 'Buat laporan',
        child: const Icon(Icons.add),
      ),
    );
  }
}
