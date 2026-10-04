import 'dart:convert';
import 'package:flutter/material.dart';
import 'report.dart';
import 'dart:typed_data';

class DetailPage extends StatelessWidget {
  final Report report;

  const DetailPage({
    super.key,
    required this.report,
  });

  Uint8List? _decodeImage() {
    try {
      String image = report.image
          .replaceAll(RegExp(r'\s'), '')
          .replaceFirst(
            RegExp(r'^data:image/[^;]+;base64,'),
            '',
          );

      if (image.isEmpty) return null;

      return base64Decode(image);
    } catch (_) {
      return null;
    }
  }

  Widget _infoSection({
    required IconData icon,
    required String title,
    required Widget content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F4F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF008F83),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                content,
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageBytes = _decodeImage();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F7),
      appBar: AppBar(
        title: const Text(
          'Detail Laporan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF008F83),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              minHeight: 220,
              maxHeight: 480,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E9E8),
              borderRadius: BorderRadius.circular(18),
            ),
            clipBehavior: Clip.antiAlias,
            child: imageBytes == null
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          size: 60,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text('Foto tidak tersedia'),
                      ],
                    ),
                  )
                : InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Image.memory(
                      imageBytes,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Text('Gagal menampilkan foto'),
                        );
                      },
                    ),
                  ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF203534),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5F4F1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    report.category,
                    style: const TextStyle(
                      color: Color(0xFF008F83),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _infoSection(
                  icon: Icons.description_outlined,
                  title: 'Deskripsi',
                  content: Text(
                    report.description.isEmpty
                        ? 'Tidak ada deskripsi.'
                        : report.description,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color(0xFF203534),
                    ),
                  ),
                ),
                _infoSection(
                  icon: Icons.location_on_outlined,
                  title: 'Lokasi GPS',
                  content: SelectableText(
                    '${report.latitude}, ${report.longitude}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF203534),
                    ),
                  ),
                ),
                _infoSection(
                  icon: Icons.calendar_month_outlined,
                  title: 'Tanggal Laporan',
                  content: Text(
                    report.createdAt,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF203534),
                    ),
                  ),
                ),
                _infoSection(
                  icon: Icons.tag,
                  title: 'ID Laporan',
                  content: Text(
                    report.id.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF203534),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}