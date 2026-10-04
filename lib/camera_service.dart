
import 'package:camera/camera.dart';

class CameraService {
  static CameraController? _controller;
  static bool _initializing = false;

  static CameraController? get controller => _controller;

  // Inisialisasi kamera
  static Future<void> initialize() async {
    if (_controller != null &&
        _controller!.value.isInitialized) {
      return;
    }

    if (_initializing) {
      throw Exception('Kamera sedang disiapkan.');
    }

    _initializing = true;

    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw Exception('Kamera tidak ditemukan.');
      }

      // Gunakan kamera pertama yang terdeteksi.
      final camera = cameras.first;

      _controller = CameraController(
        camera,
        ResolutionPreset.low,
        enableAudio: false,
      );

      await _controller!.initialize();
    } catch (e) {
      await _controller?.dispose();
      _controller = null;
      throw Exception('Gagal menginisialisasi kamera: $e');
    } finally {
      _initializing = false;
    }
  }

  // Mengambil foto
  static Future<XFile> takePhoto() async {
    final currentController = _controller;

    if (currentController == null ||
        !currentController.value.isInitialized) {
      throw Exception('Kamera belum siap.');
    }

    if (currentController.value.isTakingPicture) {
      throw Exception('Kamera sedang mengambil foto.');
    }

    try {
      return await currentController.takePicture();
    } catch (e) {
      throw Exception('Gagal mengambil foto: $e');
    }
  }

  // Menutup kamera
  static Future<void> dispose() async {
    final currentController = _controller;
    _controller = null;

    if (currentController != null) {
      await currentController.dispose();
    }
  }
}
