import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

class WebCameraService {
  html.MediaStream? _stream;
  html.VideoElement? _video;

  bool get isActive => _stream != null;

  Future<html.VideoElement> startCamera() async {
    await stopCamera();
    try {
      final devices = html.window.navigator.mediaDevices;
      if (devices == null) {
        throw Exception('Browser tidak mendukung akses kamera.');
      }

      _stream = await devices.getUserMedia({
        'video': {
          'facingMode': 'user',
          'width': {'ideal': 1280},
          'height': {'ideal': 720},
        },
        'audio': false,
      });

      _video = html.VideoElement()
        ..autoplay = true
        ..muted = true
        ..setAttribute('playsinline', 'true')
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..srcObject = _stream;

      await _video!.play();
      return _video!;
    } catch (e) {
      await stopCamera();
      throw Exception('Tidak dapat mengakses kamera: $e');
    }
  }

  Future<Uint8List> takePhoto() async {
    final video = _video;
    if (video == null || video.videoWidth == 0 || video.videoHeight == 0) {
      throw Exception('Kamera belum siap. Tunggu preview tampil.');
    }

    final canvas = html.CanvasElement(
      width: video.videoWidth,
      height: video.videoHeight,
    );
    canvas.context2D.drawImage(video, 0, 0);
    final dataUrl = canvas.toDataUrl('image/jpeg', 0.85);
    return base64Decode(dataUrl.split(',').last);
  }

  Future<void> stopCamera() async {
    final stream = _stream;
    if (stream != null) {
      for (final track in stream.getTracks()) {
        track.stop();
      }
    }
    _stream = null;
    _video?.srcObject = null;
    _video = null;
  }
}
