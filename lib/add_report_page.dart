
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'api_service.dart';
import 'location_service.dart';
import 'web_camera_view.dart';

class AddReportPage extends StatefulWidget {
  const AddReportPage({super.key});

  @override
  State<AddReportPage> createState() => _AddReportPageState();
}

class _AddReportPageState extends State<AddReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();

  Uint8List? _imageBytes;

  double? _latitude;
  double? _longitude;

  bool _loading = false;
  bool _gettingLocation = false;
  bool _takingPhoto = false;


  // Membuka kamera browser.
  Future<void> _openCamera() async {
    if (_takingPhoto) return;

    setState(() {
      _takingPhoto = true;
    });

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Kamera GeoSnap'),
            content: SizedBox(
              width: 500,
              child: WebCameraView(
                onPhotoTaken: (bytes) {
                  if (!mounted) return;

                  setState(() {
                    _imageBytes = bytes;
                  });

                  Navigator.of(dialogContext).pop();
                  _showMessage('Foto berhasil diambil.');
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Batal'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (mounted) {
        _showMessage('Gagal membuka kamera: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _takingPhoto = false;
        });
      }
    }
  }

  // Mengambil lokasi GPS.
  Future<void> _getLocation() async {
    if (_gettingLocation) return;

    setState(() {
      _gettingLocation = true;
    });

    try {
      final position = await LocationService.getCurrentLocation();

      if (!mounted) return;

      if (position == null) {
        _showMessage('Lokasi tidak tersedia atau izin ditolak.');
      } else {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });

        _showMessage('Lokasi berhasil didapatkan.');
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Gagal mendapatkan lokasi: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _gettingLocation = false;
        });
      }
    }
  }

  // Menyimpan laporan ke API.
  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageBytes == null) {
      _showMessage('Silakan ambil foto terlebih dahulu.');
      return;
    }

    if (_latitude == null || _longitude == null) {
      _showMessage('Silakan ambil lokasi GPS terlebih dahulu.');
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final success = await ApiService.addReport(
        title: _titleController.text.trim(),
        category: _categoryController.text.trim(),
        description: _descriptionController.text.trim(),
        latitude: _latitude!,
        longitude: _longitude!,
        imageBytes: _imageBytes!,
      );

      if (!mounted) return;

      if (success) {
        _showMessage('Laporan berhasil disimpan.');
        Navigator.pop(context, true);
      } else {
        _showMessage('Gagal menyimpan laporan.');
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Terjadi kesalahan: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // Menampilkan notifikasi.
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Laporan'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Judul laporan.
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Laporan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul wajib diisi.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Kategori dapat ditulis secara manual.
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  hintText: 'Contoh: Jalan Berlubang',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Kategori wajib diisi.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Deskripsi laporan.
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 20),

              // Foto laporan.
              const Text(
                'Foto Laporan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              if (_imageBytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    _imageBytes!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),

              const SizedBox(height: 10),

              OutlinedButton.icon(
                onPressed: _takingPhoto ? null : _openCamera,
                icon: const Icon(Icons.camera_alt),
                label: Text(
                  _takingPhoto
                      ? 'Membuka kamera...'
                      : 'Buka Kamera',
                ),
              ),

              const SizedBox(height: 20),

              // Lokasi GPS.
              const Text(
                'Lokasi GPS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              if (_latitude != null && _longitude != null)
                Text(
                  'Latitude: $_latitude\n'
                  'Longitude: $_longitude',
                )
              else
                const Text('Lokasi belum diambil.'),

              const SizedBox(height: 10),

              OutlinedButton.icon(
                onPressed: _gettingLocation ? null : _getLocation,
                icon: const Icon(Icons.location_on),
                label: Text(
                  _gettingLocation
                      ? 'Mengambil lokasi...'
                      : 'Ambil Lokasi GPS',
                ),
              ),

              const SizedBox(height: 30),

              // Tombol simpan laporan.
              ElevatedButton(
                onPressed: _loading ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Simpan Laporan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
