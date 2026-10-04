
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'report.dart';

class ApiService {
  static const String baseUrl = 'http://localhost/geosnap_api';

  // Membaca respons JSON dengan penanganan error.
  static Map<String, dynamic> _parseResponse(
    String body,
    String operation,
  ) {
    if (body.trim().isEmpty) {
      throw Exception(
        'Respons server kosong saat $operation.',
      );
    }

    try {
      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw Exception('Format respons server tidak valid.');
    } on FormatException {
      throw Exception(
        'Respons server bukan JSON valid saat $operation: $body',
      );
    }
  }

  // Mengambil semua laporan dari database.
  static Future<List<Report>> fetchReports() async {
    final response = await http
        .get(Uri.parse('$baseUrl/get_reports.php'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'HTTP ${response.statusCode}: ${response.body}',
      );
    }

    final result = _parseResponse(
      response.body,
      'mengambil laporan',
    );

    if (result['success'] == true) {
      final List data = result['data'] ?? [];

      return data
          .map((item) => Report.fromJson(item))
          .toList();
    }

    throw Exception(
      result['message'] ?? 'Gagal mengambil laporan.',
    );
  }

  // Mengirim laporan baru ke database.
  static Future<bool> addReport({
    required String title,
    required String category,
    required String description,
    required double latitude,
    required double longitude,
    required Uint8List imageBytes,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/add_report.php'),
    );

    request.fields.addAll({
      'title': title,
      'category': category,
      'description': description,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
    });

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'report.jpg',
      ),
    );

    final streamedResponse = await request
        .send()
        .timeout(const Duration(seconds: 30));

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'HTTP ${response.statusCode}: ${response.body}',
      );
    }

    final result = _parseResponse(
      response.body,
      'menyimpan laporan',
    );

    if (result['success'] == true) {
      return true;
    }

    throw Exception(
      result['message'] ?? 'Gagal menyimpan laporan.',
    );
  }

  // Menghapus laporan berdasarkan ID.
  static Future<bool> deleteReport(int id) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/delete_report.php'),
          body: {
            'id': id.toString(),
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'HTTP ${response.statusCode}: ${response.body}',
      );
    }

    final result = _parseResponse(
      response.body,
      'menghapus laporan',
    );

    if (result['success'] == true) {
      return true;
    }

    throw Exception(
      result['message'] ?? 'Gagal menghapus laporan.',
    );
  }
}
